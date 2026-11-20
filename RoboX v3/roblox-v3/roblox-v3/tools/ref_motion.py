"""ref_motion.py: camera and subject motion per shot from dense optical flow (needs analysis.json from ref_cuts.py).
Per shot: translation, divergence (push-in > 0), curl (roll), residual (subject motion). Run in the folder holding proxy/."""
import sys, os, json, glob
import cv2, numpy as np

A = json.load(open("analysis.json"))
out = {}
for p in sorted(glob.glob("proxy/*.mp4")):
    name = os.path.basename(p)[:-4]
    cuts = A[name]["cuts"]; n = A[name]["n"]
    cap = cv2.VideoCapture(p)
    prev = None; idx = 0
    yy, xx = np.mgrid[0:240, 0:135].astype(np.float32)
    xx -= 67.5; yy -= 120
    shots = []; cur = dict(tx=[], ty=[], div=[], curl=[], res=[])
    cutset = set(cuts)
    while True:
        ok, im = cap.read()
        if not ok: break
        g = cv2.cvtColor(cv2.resize(im, (135, 240), interpolation=cv2.INTER_AREA), cv2.COLOR_BGR2GRAY)
        if idx in cutset:
            shots.append(cur); cur = dict(tx=[], ty=[], div=[], curl=[], res=[]); prev = None
        if prev is not None:
            f = cv2.calcOpticalFlowFarneback(prev, g, None, 0.5, 3, 15, 3, 5, 1.2, 0)
            u, v = f[..., 0], f[..., 1]
            tx, ty = float(np.median(u)), float(np.median(v))
            # least squares: u = a + d*x - c*y ; v = b + d*y + c*x  (d = zoom, c = roll)
            M = np.stack([np.ones(xx.size), xx.ravel(), -yy.ravel()], 1)
            su = np.linalg.lstsq(M[::7], u.ravel()[::7], rcond=None)[0]
            M2 = np.stack([np.ones(xx.size), yy.ravel(), xx.ravel()], 1)
            sv = np.linalg.lstsq(M2[::7], v.ravel()[::7], rcond=None)[0]
            d = (su[1] + sv[1]) / 2; c = (su[2] + sv[2]) / 2
            res = np.sqrt((u - (su[0] + su[1] * xx - su[2] * yy)) ** 2 + (v - (sv[0] + sv[1] * yy + sv[2] * xx)) ** 2)
            cur["tx"].append(tx); cur["ty"].append(ty); cur["div"].append(float(d)); cur["curl"].append(float(c)); cur["res"].append(float(np.mean(res)))
        prev = g; idx += 1
    shots.append(cur)
    cap.release()
    out[name] = shots
    print(name, len(shots), flush=True)
json.dump(out, open("motion.json", "w"))
