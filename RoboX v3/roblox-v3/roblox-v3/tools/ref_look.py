"""ref_look.py: look metrics of frames or a video: luma, contrast, shadow depth, saturation (and the share of screaming pixels), local texture, flat/blurred share, warm bias, hue entropy.
  python ref_look.py video file.mp4 36 [out.json]      36 frames spread over the video
  python ref_look.py frames "dir/*.jpg" 0 [out.json]
Used 2026-11-20 to compare our frames with the @Gneef Shorts (gneef-study.md section 10)."""
import sys, glob, os, json, subprocess
import cv2, numpy as np

def metrics(im):
    im = cv2.resize(im, (1080, 1920), interpolation=cv2.INTER_AREA) if im.shape[1] != 1080 else im
    h = im.shape[0]; im = im[int(h * .06):int(h * .80)]          # skip caption band at the bottom
    g = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY).astype(np.float32)
    hsv = cv2.cvtColor(im, cv2.COLOR_BGR2HSV).astype(np.float32)
    s = hsv[..., 1] / 255; v = hsv[..., 2] / 255
    lap = np.abs(cv2.Laplacian(cv2.GaussianBlur(g, (0, 0), 0.8), cv2.CV_32F))
    gx = cv2.Sobel(g, cv2.CV_32F, 1, 0); gy = cv2.Sobel(g, cv2.CV_32F, 0, 1); grad = np.hypot(gx, gy)
    # blur share: 32x32 blocks with almost no gradient
    bl = cv2.resize(grad, (grad.shape[1] // 32, grad.shape[0] // 32), interpolation=cv2.INTER_AREA)
    # colour spread: entropy of hue histogram over saturated pixels
    hh = hsv[..., 0][(s > .25) & (v > .2)]
    hist = np.histogram(hh, bins=18, range=(0, 180))[0].astype(float); hist /= max(hist.sum(), 1)
    ent = float(-(hist[hist > 0] * np.log2(hist[hist > 0])).sum())
    # high-sat share (screaming colours)
    return dict(luma=g.mean() / 255, contrast=g.std() / 255, p2=np.percentile(g, 2) / 255, p98=np.percentile(g, 98) / 255,
                sat=s.mean(), sat_hi=float((s > .8).mean()), texture=float(lap.mean()), edge=float(grad.mean()),
                flat=float((bl < 2.0).mean()), warm=float((im[..., 2].astype(float) - im[..., 0]).mean() / 255),
                hue_entropy=ent, dark=float((g < 25).mean()), bright=float((g > 235).mean()))

if __name__ == "__main__":
    mode = sys.argv[1]
    rows = []
    if mode == "video":
        vid, n = sys.argv[2], int(sys.argv[3])
        dur = float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", vid]))
        for k in range(n):
            t = dur * (k + 0.5) / n
            raw = subprocess.check_output(["ffmpeg", "-v", "error", "-ss", f"{t:.2f}", "-i", vid, "-frames:v", "1", "-vf", "scale=1080:-1", "-f", "image2pipe", "-vcodec", "png", "-"])
            rows.append(metrics(cv2.imdecode(np.frombuffer(raw, np.uint8), cv2.IMREAD_COLOR)))
    else:
        for f in sorted(glob.glob(sys.argv[2])):
            rows.append(metrics(cv2.imread(f)))
    keys = rows[0].keys()
    out = {k: (float(np.median([r[k] for r in rows])), float(np.percentile([r[k] for r in rows], 25)), float(np.percentile([r[k] for r in rows], 75))) for k in keys}
    print(sys.argv[2], "n=%d" % len(rows))
    for k, (m, a, b) in out.items(): print(f"  {k:12s} median {m:.3f}  [{a:.3f} .. {b:.3f}]")
    if len(sys.argv) > 4: json.dump(out, open(sys.argv[4], "w"))
