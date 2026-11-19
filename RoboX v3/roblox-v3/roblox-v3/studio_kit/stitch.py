#!/usr/bin/env python
"""Join the pitched captures of each frame into sharp portrait frames.

  python stitch.py --ep <episode> [--tiles 2|4] [--redo] [--jobs 2] [all | s001 s002 ...]

--tiles 2 (default): frames/raw2/<id>/ (upper, lower, upper, ...) -> frames/hd/<id>/NNNNN.jpg, 1080x1920, needs fov.json.
--tiles 4:           frames/raw4/<id>/ (R rows per frame)         -> frames/4k/<id>/NNNNN.jpg, 2160x3840, needs tiles4k.json.
Every tile is the same camera centre turned by a pitch, so it maps by an exact homography (no parallax, no seam); the
overlaps are feathered. Frames already stitched are skipped unless --redo, so it is safe to run while render.py is still
capturing (it stitches what is complete). --jobs N uses N processes."""
import json, os, sys
from functools import lru_cache
from multiprocessing import Pool
import cv2, numpy as np
import episode

_cache = {}


def plan(V, Ft, pitches, W, H, w, h, feather):
    """Per-tile remap bands for an output W x H from captures w x h. V = output vertical FOV, Ft = tile vertical FOV."""
    key = (round(V, 4), round(Ft, 4), tuple(round(p, 4) for p in pitches), W, H, w, h)
    if key in _cache:
        return _cache[key]
    V, Ft = np.radians(V), np.radians(Ft)
    fo = (H / 2) / np.tan(V / 2); ft = (h / 2) / np.tan(Ft / 2)
    u, v = np.meshgrid(np.arange(W, dtype=np.float32) + 0.5, np.arange(H, dtype=np.float32) + 0.5)
    x = (u - W / 2) / fo; y = -(v - H / 2) / fo; z = -np.ones_like(x)
    maps, wts = [], []
    for p in pitches:
        d = np.radians(p)
        yt = np.cos(d) * y + np.sin(d) * z
        zt = -np.sin(d) * y + np.cos(d) * z
        mx = (w / 2 + ft * x / (-zt)).astype(np.float32)
        my = (h / 2 - ft * yt / (-zt)).astype(np.float32)
        wy = np.clip(np.minimum(my, h - my) / feather, 0, 1)
        wx = np.clip(np.minimum(mx, w - mx) / feather, 0, 1)
        maps.append((mx - 0.5, my - 0.5)); wts.append((wy * wx).astype(np.float32))
    tot = np.maximum(sum(wts), 1e-6)
    bands = []
    for (mx, my), wi in zip(maps, wts):
        wn = wi / tot
        rows = np.where(wn.max(axis=1) > 1e-4)[0]
        r0, r1 = int(rows.min()), int(rows.max()) + 1
        bands.append((r0, r1, np.ascontiguousarray(mx[r0:r1]), np.ascontiguousarray(my[r0:r1]), np.ascontiguousarray(wn[r0:r1, :, None])))
    if len(_cache) > 8:
        _cache.clear()
    _cache[key] = bands
    return bands


def compose(ims, bands, W, H):
    acc = np.zeros((H, W, 3), np.float32)
    for im, (r0, r1, mx, my, wt) in zip(ims, bands):
        acc[r0:r1] += cv2.remap(im, mx, my, cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE).astype(np.float32) * wt
    return np.clip(acc, 0, 255).astype(np.uint8)


@lru_cache(maxsize=None)
def geometry(ep, tiles, sid):
    """(rows, V, Ft, pitches, W, H, feather) for one shot."""
    if tiles == 2:
        V = json.load(open(episode.path(ep, "fov.json")))[sid]
        return 2, V, V / 2 + 6.0, (V / 4, -V / 4), 1080, 1920, 24.0      # MT.frameTile: pitch +-V/4, FOV V/2 + TILE_MARGIN (6)
    t = json.load(open(episode.path(ep, "tiles4k.json")))[sid]
    return t["rows"], t["V"], t["Ft"], tuple(t["p"]), 2160, 3840, 40.0


def task(a):
    ep, tiles, sid, i, redo = a
    R, V, Ft, P, W, H, feather = geometry(ep, tiles, sid)
    src = episode.path(ep, "frames", f"raw{tiles}", sid)
    dst = episode.path(ep, "frames", "hd" if tiles == 2 else "4k", sid)
    out = os.path.join(dst, f"{i + 1:05d}.jpg")
    if os.path.exists(out) and not redo:
        return 0
    ims = [cv2.imread(os.path.join(src, f"{i * R + k + 1:05d}.png")) for k in range(R)]
    if any(im is None for im in ims):
        return 0
    h, w = ims[0].shape[:2]
    img = compose(ims, plan(V, Ft, P, W, H, w, h, feather), W, H)
    os.makedirs(dst, exist_ok=True)
    cv2.imwrite(out + ".tmp.jpg", img, [cv2.IMWRITE_JPEG_QUALITY, 95]); os.replace(out + ".tmp.jpg", out)
    return 1


if __name__ == "__main__":
    argv = sys.argv[1:]
    ep = episode.ep_dir(argv)
    tiles = int(episode.pop_flag(argv, "--tiles", "2"))
    redo = bool(episode.pop_flag(argv, "--redo", False, has_value=False))
    jobs_n = int(episode.pop_flag(argv, "--jobs", "1"))
    if tiles not in (2, 4):
        sys.exit("--tiles is 2 or 4 (1-tile captures need no stitching)")
    need = "fov.json" if tiles == 2 else "tiles4k.json"
    if not os.path.exists(episode.path(ep, need)):
        sys.exit(f"no {need} in the episode (run fov.py{'' if tiles == 2 else ' and tiles4k.py'})")
    jobs, report = [], []
    for sid, n in episode.pick(ep, argv):
        R = geometry(ep, tiles, sid)[0]
        src = episode.path(ep, "frames", f"raw{tiles}", sid)
        have = len([f for f in os.listdir(src) if f[:5].isdigit()]) // R if os.path.isdir(src) else 0
        jobs += [(ep, tiles, sid, i, redo) for i in range(min(have, n))]
        report.append(f"{sid}:{min(have, n)}/{n}")
    if jobs_n > 1:
        with Pool(jobs_n) as p:
            done = sum(p.imap(task, jobs, chunksize=4))
    else:
        done = sum(task(j) for j in jobs)
    print("stitched", done, "new frames; captured per shot:", " ".join(report))
