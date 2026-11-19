#!/usr/bin/env python
"""Second mouth for every face, so talking moves only the mouth.

  python make_talk_faces.py <folder with the make_faces_v2 PNGs>      -> <name>_t.png next to each face

Swapping a whole face decal to "talk" every few frames also swaps the eyes and brows, and the face seems to flicker
(E01, 2026-11-19). <name>_t keeps the eyes, brows, blush and sweat of <name> and only changes the mouth: a closed mouth
becomes open, an open mouth becomes a small closed smile. lib10 flaps between <name> and <name>_t when the shot says
speak = <actor>, and the episode's chatter helper does the same for crowds.
"""
import os, sys
from PIL import Image, ImageDraw
import numpy as np

S = 4                          # draw at 4x, then shrink (same as make_faces_v2)
INK = (22, 18, 24, 255); MOUTH = (92, 22, 34, 255); TONGUE = (238, 110, 128, 255); WHITE = (255, 255, 255, 255)
BOX = (110, 680, 914, 1010)    # mouth area on the 1024 px face (eyes and blush end above y 670)


def is_open(a):
    """True when the face's own mouth is drawn open (much dark-red fill inside the mouth box)."""
    x0, y0, x1, y1 = BOX
    reg = a[y0:y1, x0:x1]
    red = (reg[..., 3] > 200) & (reg[..., 0] > 70) & (reg[..., 0] < 140) & (reg[..., 1] < 50) & (reg[..., 2] < 60)
    return red.sum() > 1500


def mouth_center(a):
    x0, y0, x1, y1 = BOX
    ys, xs = np.where(a[y0:y1, x0:x1, 3] > 40)
    return (512, int(y0 + ys.mean())) if len(ys) else (512, 800)


def draw_open(d, cx, cy):
    rx, ry = 104, 78
    d.ellipse([(cx - rx) * S, (cy - ry) * S, (cx + rx) * S, (cy + ry) * S], fill=MOUTH, outline=INK, width=16 * S)
    d.rectangle([(cx - 70) * S, (cy - ry + 12) * S, (cx + 70) * S, (cy - ry + 38) * S], fill=WHITE)          # top teeth
    d.ellipse([(cx - 56) * S, (cy + 16) * S, (cx + 56) * S, (cy + ry - 10) * S], fill=TONGUE)                # tongue


def draw_closed(d, cx, cy):
    pts = [((cx - 95 + i * 9.5) * S, (cy - 8 + 34 * (1 - ((i - 10) / 10) ** 2)) * S) for i in range(21)]
    d.line(pts, fill=INK, width=18 * S, joint="curve")


def make(src, dst):
    im = Image.open(src).convert("RGBA")
    a = np.array(im)
    cx, cy = mouth_center(a)
    opened = is_open(a)
    x0, y0, x1, y1 = BOX
    a[y0:y1, x0:x1, 3] = 0                                          # clear the old mouth
    big = Image.new("RGBA", (1024 * S, 1024 * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    (draw_closed if opened else draw_open)(d, cx, cy)
    m = big.resize((1024, 1024), Image.LANCZOS)
    out = Image.alpha_composite(Image.fromarray(a), m)
    out.save(dst)
    return opened


if __name__ == "__main__":
    folder = sys.argv[1] if len(sys.argv) > 1 else "out"
    n = 0
    for f in sorted(os.listdir(folder)):
        if f.endswith(".png") and not f.endswith("_t.png"):
            o = make(os.path.join(folder, f), os.path.join(folder, f[:-4] + "_t.png"))
            print(f"{f[:-4]:12s} own mouth {'open -> closed' if o else 'closed -> open'}"); n += 1
    print(n, "talk faces")
