"""ref_cuts.py: cuts, shot lengths, light and colour per frame of reference videos (30 fps proxies in).
  1. proxies: ffmpeg -i ref.mkv -vf "fps=30,scale=540:960:flags=area" -an -c:v libx264 -crf 14 proxy/NAME.mp4
  2. python ref_cuts.py proxy analysis.json, then python ref_motion.py in the same folder (it reads analysis.json).
Used on five @Gneef Shorts on 2026-11-20 (gneef-study.md). Validated on E03: found 35 cuts, true 33."""
import sys, os, json, glob
import cv2, numpy as np

def analyze(path):
    cap = cv2.VideoCapture(path)
    n = int(cap.get(cv2.CAP_PROP_FRAME_COUNT)); fps = cap.get(cv2.CAP_PROP_FPS)
    prev = None; small_prev = None
    rows = []
    while True:
        ok, im = cap.read()
        if not ok: break
        g = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
        s = cv2.resize(g, (54, 96), interpolation=cv2.INTER_AREA).astype(np.float32)
        hsv = cv2.cvtColor(cv2.resize(im, (108, 192), interpolation=cv2.INTER_AREA), cv2.COLOR_BGR2HSV)
        h, w = g.shape
        corner = g[:h // 6, :w // 6].mean(), g[:h // 6, -w // 6:].mean(), g[-h // 6:, :w // 6].mean(), g[-h // 6:, -w // 6:].mean()
        centre = g[h // 3:2 * h // 3, w // 3:2 * w // 3].mean()
        diff = float(np.abs(s - small_prev).mean()) if small_prev is not None else 0.0
        # global motion (phase correlation) and residual after removing it
        shift = (0.0, 0.0)
        if prev is not None:
            (dx, dy), resp = cv2.phaseCorrelate(prev.astype(np.float32), s)
            shift = (dx, dy)
        rows.append(dict(diff=diff, mean=float(g.mean()), std=float(g.std()), sat=float(hsv[..., 1].mean() / 255),
                         hue=float(np.median(hsv[..., 0][hsv[..., 1] > 50])) * 2 if (hsv[..., 1] > 50).any() else -1,
                         p1=float(np.percentile(g, 1)), p99=float(np.percentile(g, 99)),
                         vign=float(np.mean(corner) / max(centre, 1)), dx=shift[0], dy=shift[1],
                         warm=float((im[..., 2].astype(float) - im[..., 0]).mean() / 255)))
        prev = s; small_prev = s
    cap.release()
    d = np.array([r["diff"] for r in rows])
    # cuts: frame-to-frame jump much larger than neighbourhood
    cuts = []
    for i in range(1, len(d)):
        loc = np.median(d[max(0, i - 8):i + 8]) + 1.0
        if d[i] > max(9.0, 4.5 * loc): cuts.append(i)
    # merge cuts within 3 frames
    merged = []
    for c in cuts:
        if not merged or c - merged[-1] > 3: merged.append(c)
    return fps, rows, merged

if __name__ == "__main__":
    out = {}
    for p in sorted(glob.glob(sys.argv[1] + "/*.mp4")):
        name = os.path.basename(p)[:-4]
        fps, rows, cuts = analyze(p)
        out[name] = dict(fps=fps, n=len(rows), cuts=cuts, rows=rows)
        print(name, "frames", len(rows), "cuts", len(cuts), flush=True)
    json.dump(out, open(sys.argv[2], "w"))
