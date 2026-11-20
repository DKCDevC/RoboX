#!/usr/bin/env python
"""Give the flat clothing templates (make_clothes.py) a fabric look: woven/knit pattern, grain, dye mottling, fold shading, calmer colour.

  python fabricize.py <cloth_dir> <out_dir> [--knit 0.05] [--grain 0.04] [--folds 0.10] [--sat 0.82]
Reads every shirt_*.png / pants_*.png (585x559 Roblox classic templates), writes the same names into out_dir. Then copy out_dir to
%LOCALAPPDATA%\\Roblox\\Versions\\version-<hash>\\content\\textures\\<new folder> and point lua/cloth.lua at it (use a NEW folder name:
Studio keeps failed lookups until it restarts). Added 2026-11-20 after comparing our flat shirts with the knit sweaters in @Gneef frames."""
import sys, os, glob
import numpy as np
from PIL import Image, ImageFilter


def noise(h, w, sigma, rng):
    n = rng.standard_normal((h, w)).astype(np.float32)
    im = Image.fromarray(((n - n.min()) / (n.max() - n.min()) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(sigma))
    a = np.asarray(im, np.float32) / 255
    return (a - a.mean()) / max(a.std(), 1e-6)


def fabricize(img, knit, grain, folds, sat, rng, name):
    a = np.asarray(img.convert("RGBA"), np.float32) / 255
    rgb, al = a[..., :3], a[..., 3:4]
    h, w = rgb.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    shirt = name.startswith("shirt")
    cable = "hero" in name
    # knit / weave: rows of V stitches (shirts) or a fine twill (pants)
    if shirt and cable:      # cable knit: vertical twisted ribs, 11 px apart, plus a fine stitch
        rib = np.sin(2 * np.pi * (xx + 3.0 * np.sin(yy / 9.0)) / 11.0)
        pat = 0.75 * rib + 0.25 * np.sin(2 * np.pi * yy / 5.0)
    elif shirt:
        period = 7.0
        row = np.sin(2 * np.pi * yy / period)
        col = np.sin(2 * np.pi * (xx + (np.floor(yy / period) % 2) * period / 2) / period)
        pat = 0.6 * row + 0.4 * col
    else:
        pat = np.sin(2 * np.pi * (xx + yy) / 4.0) * 0.7 + np.sin(2 * np.pi * (xx - yy) / 9.0) * 0.3
    lum = 1 + knit * pat
    lum = lum + grain * noise(h, w, 0.6, rng)                 # fibre grain
    lum = lum + (0.02 if cable else 0.05) * noise(h, w, 18, rng)   # dye mottling (less on the cream sweater)
    # folds: soft dark bands across the limbs and torso (a few random diagonal creases per template)
    f = np.zeros((h, w), np.float32)
    for _ in range(28):
        cx, cy = rng.uniform(0, w), rng.uniform(0, h); ang = rng.uniform(-0.6, 0.6); ln = rng.uniform(25, 70); wd = rng.uniform(3, 7)
        d = (xx - cx) * np.sin(ang) - (yy - cy) * np.cos(ang)       # distance across the crease
        s = (xx - cx) * np.cos(ang) + (yy - cy) * np.sin(ang)       # position along it
        f += np.exp(-(d / wd) ** 2) * np.exp(-(s / ln) ** 2) * rng.uniform(0.4, 1.0)
    lum = lum - folds * np.clip(f, 0, 1.4)
    out = rgb * lum[..., None]
    # calmer colour: pull saturation down a little and warm the shadows
    g = out.mean(axis=2, keepdims=True)
    out = g + (out - g) * sat
    out = np.clip(out, 0, 1)
    return Image.fromarray((np.concatenate([out, al], axis=2) * 255).astype(np.uint8), "RGBA")


if __name__ == "__main__":
    argv = sys.argv[1:]
    def opt(n, d):
        return float(argv[argv.index(n) + 1]) if n in argv else d
    src, dst = argv[0], argv[1]
    os.makedirs(dst, exist_ok=True)
    for p in sorted(glob.glob(os.path.join(src, "*.png"))):
        name = os.path.basename(p)
        if not (name.startswith("shirt") or name.startswith("pants")):
            continue
        rng = np.random.default_rng(abs(hash(name)) % (2 ** 32))
        fabricize(Image.open(p), opt("--knit", 0.05), opt("--grain", 0.04), opt("--folds", 0.10), opt("--sat", 0.82), rng, name).save(os.path.join(dst, name))
    print("wrote", len(glob.glob(os.path.join(dst, "*.png"))), "templates to", dst)
