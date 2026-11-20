#!/usr/bin/env python
"""Minimal Roblox-style faces like the @Gneef hero: small vertical-oval dot eyes, short brows, a small mouth, on the lower half of the head.
Compared 2026-11-20 with his 4K frames (gneef-study.md section 10/11): his features are small and thin, ours (make_faces_v2.py) were big and heavy.

  python make_faces_gneef.py <out_dir> [--names angry,blink,...]    writes <name>.png and <name>_t.png (talking mouth) at 1024x1024, transparent
Same names as make_faces_v2.py / lua/faces.lua, so only the folder in faces.lua changes. Copy <out_dir> into Studio's content/textures/<new folder>.
The head mesh is stretched taller (spec.headScale), so the dots come out as vertical ovals, which is the look."""
import sys, os
from PIL import Image, ImageDraw

S = 4                    # supersample
W = 1024 * S
INK = (22, 16, 14, 255)
RED = (190, 40, 50, 255)
BLUSH = (255, 120, 120, 120)

NAMES = "angry blink confused content creepy cry deadpan determined disgusted dizzy embarrassed evil exhausted furious happy heartbroken laugh nerd nervous neutral oh power sad scared shocked sleepy smile smirk sparkle sparkle_oh squeeze stare suspicious talk terrified wink".split()
# name -> (kind, extras)
KIND = {
    "neutral": "neutral", "deadpan": "flat", "stare": "stare", "content": "smile", "smile": "smile", "happy": "happy", "laugh": "laugh",
    "wink": "wink", "smirk": "smirk", "evil": "evil", "sparkle": "happy", "sparkle_oh": "shocked", "squeeze": "squeeze", "power": "determined",
    "sad": "sad", "heartbroken": "cry", "cry": "cry", "nervous": "worried", "scared": "scared", "terrified": "scared", "shocked": "shocked",
    "oh": "shocked", "angry": "angry", "furious": "angry", "determined": "determined", "suspicious": "suspicious", "disgusted": "disgusted",
    "confused": "confused", "embarrassed": "embarrassed", "exhausted": "tired", "sleepy": "tired", "blink": "blink", "dizzy": "dizzy",
    "creepy": "creepy", "nerd": "neutral", "talk": "neutral",
}


def px(v): return int(v * W)


def draw_face(kind, talk=False):
    im = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    ex, ey = 0.40, 0.58                     # eye centres (x offset from 0.5 each side, y)
    lw = px(0.021)                           # line width
    r_x, r_y = px(0.021), px(0.036)          # dot eye radii (vertical ovals)

    def dot(cx, cy, rx=r_x, ry=r_y):
        d.ellipse([px(cx) - rx, px(cy) - ry, px(cx) + rx, px(cy) + ry], fill=INK)

    def ring(cx, cy, rx, ry, pupil=0.45):
        d.ellipse([px(cx) - rx, px(cy) - ry, px(cx) + rx, px(cy) + ry], fill=(250, 250, 248, 255), outline=INK, width=lw)
        pr = int(rx * pupil); d.ellipse([px(cx) - pr, px(cy) - pr, px(cx) + pr, px(cy) + pr], fill=INK)

    def line(a, b, w=lw):
        d.line([(px(a[0]), px(a[1])), (px(b[0]), px(b[1]))], fill=INK, width=w)
        for p in (a, b): d.ellipse([px(p[0]) - w // 2, px(p[1]) - w // 2, px(p[0]) + w // 2, px(p[1]) + w // 2], fill=INK)

    def arc(box, a0, a1, w=lw):
        d.arc([px(box[0]), px(box[1]), px(box[2]), px(box[3])], a0, a1, fill=INK, width=w)

    L, R = 0.5 - ex * 0.5 + 0.0, 0.5 + ex * 0.5     # 0.3225 and 0.6775
    mx, my = 0.5, 0.73
    mouth = "flat"
    if kind in ("neutral", "flat", "stare", "smile", "smirk", "squeeze", "wink", "happy", "laugh"):
        pass
    # eyes
    if kind in ("neutral", "flat", "smile", "smirk", "sad", "worried", "angry", "determined", "suspicious", "confused", "creepy", "disgusted", "embarrassed", "evil", "cry"):
        dot(L, ey); dot(R, ey)
    if kind == "stare": dot(L, ey, int(r_x * 1.2), int(r_y * 1.2)); dot(R, ey, int(r_x * 1.2), int(r_y * 1.2))
    if kind == "happy" or kind == "laugh":
        arc((L - 0.03, ey - 0.02, L + 0.03, ey + 0.05), 200, 340); arc((R - 0.03, ey - 0.02, R + 0.03, ey + 0.05), 200, 340)
    if kind == "wink":
        dot(L, ey); line((R - 0.03, ey), (R + 0.03, ey))
    if kind == "blink" or kind == "tired":
        line((L - 0.03, ey + 0.01), (L + 0.03, ey + 0.01)); line((R - 0.03, ey + 0.01), (R + 0.03, ey + 0.01))
    if kind == "squeeze":
        line((L - 0.03, ey - 0.02), (L + 0.025, ey + 0.012)); line((L - 0.03, ey + 0.045), (L + 0.025, ey + 0.012))
        line((R + 0.03, ey - 0.02), (R - 0.025, ey + 0.012)); line((R + 0.03, ey + 0.045), (R - 0.025, ey + 0.012))
    if kind in ("scared", "shocked"):
        ring(L, ey, px(0.04), px(0.05), 0.4); ring(R, ey, px(0.04), px(0.05), 0.4)
    if kind == "dizzy":
        for c in (L, R):
            arc((c - 0.035, ey - 0.04, c + 0.035, ey + 0.04), 0, 270); arc((c - 0.015, ey - 0.018, c + 0.015, ey + 0.018), 180, 450)
    # brows
    by = ey - 0.075
    if kind in ("sad", "cry", "worried", "scared"):
        line((L - 0.035, by + 0.012), (L + 0.03, by - 0.012), int(lw * 0.8)); line((R + 0.035, by + 0.012), (R - 0.03, by - 0.012), int(lw * 0.8))
    elif kind in ("angry", "determined", "evil", "creepy"):
        line((L - 0.035, by - 0.016), (L + 0.03, by + 0.012), lw); line((R + 0.035, by - 0.016), (R - 0.03, by + 0.012), lw)
    elif kind in ("suspicious", "smirk", "confused"):
        line((L - 0.03, by + 0.004), (L + 0.03, by + 0.004), int(lw * 0.8)); line((R - 0.03, by - 0.014), (R + 0.03, by - 0.004), int(lw * 0.8))
    elif kind in ("shocked", "surprise"):
        line((L - 0.03, by - 0.02), (L + 0.03, by - 0.02), int(lw * 0.8)); line((R - 0.03, by - 0.02), (R + 0.03, by - 0.02), int(lw * 0.8))
    elif kind in ("neutral", "stare", "disgusted", "embarrassed"):
        line((L - 0.028, by), (L + 0.028, by), int(lw * 0.7)); line((R - 0.028, by), (R + 0.028, by), int(lw * 0.7))
    # mouth
    if talk and kind not in ("blink",):
        d.ellipse([px(mx - 0.035), px(my - 0.012), px(mx + 0.035), px(my + 0.045)], fill=INK)
        d.ellipse([px(mx - 0.02), px(my + 0.018), px(mx + 0.02), px(my + 0.042)], fill=RED)
    elif kind in ("neutral", "flat", "stare", "blink", "creepy"):
        line((mx - 0.04, my + 0.01), (mx + 0.04, my + 0.01), int(lw * 0.8))
    elif kind in ("smile", "wink", "content"):
        arc((mx - 0.06, my - 0.05, mx + 0.06, my + 0.03), 20, 160)
    elif kind == "happy":
        d.chord([px(mx - 0.06), px(my - 0.04), px(mx + 0.06), px(my + 0.05)], 0, 180, fill=INK)
    elif kind == "laugh":
        d.chord([px(mx - 0.07), px(my - 0.04), px(mx + 0.07), px(my + 0.07)], 0, 180, fill=INK); d.chord([px(mx - 0.035), px(my + 0.02), px(mx + 0.035), px(my + 0.07)], 0, 180, fill=RED)
    elif kind == "smirk":
        arc((mx - 0.03, my - 0.05, mx + 0.08, my + 0.03), 10, 130); line((mx - 0.04, my + 0.012), (mx - 0.01, my + 0.016))
    elif kind in ("sad", "cry", "worried", "disgusted", "tired"):
        arc((mx - 0.05, my - 0.0, mx + 0.05, my + 0.07), 200, 340)
    elif kind in ("scared",):
        arc((mx - 0.05, my + 0.005, mx + 0.05, my + 0.06), 190, 350); line((mx - 0.03, my + 0.01), (mx + 0.03, my + 0.01), int(lw * 0.5))
    elif kind in ("shocked",):
        d.ellipse([px(mx - 0.03), px(my - 0.01), px(mx + 0.03), px(my + 0.06)], fill=INK); d.ellipse([px(mx - 0.017), px(my + 0.015), px(mx + 0.017), px(my + 0.05)], fill=RED)
    elif kind in ("angry", "determined"):
        d.rectangle([px(mx - 0.045), px(my - 0.004), px(mx + 0.045), px(my + 0.03)], fill=(250, 250, 248, 255), outline=INK, width=int(lw * 0.8)); line((mx - 0.045, my + 0.013), (mx + 0.045, my + 0.013), int(lw * 0.5))
    elif kind in ("evil",):
        arc((mx - 0.07, my - 0.05, mx + 0.07, my + 0.04), 15, 165)
    elif kind in ("suspicious", "confused"):
        line((mx - 0.04, my + 0.016), (mx + 0.04, my + 0.002), int(lw * 0.8))
    elif kind in ("embarrassed",):
        arc((mx - 0.03, my - 0.0, mx + 0.03, my + 0.04), 200, 340)
    elif kind == "dizzy":
        d.ellipse([px(mx - 0.025), px(my), px(mx + 0.025), px(my + 0.05)], outline=INK, width=lw)
    elif kind == "squeeze":
        arc((mx - 0.05, my - 0.01, mx + 0.05, my + 0.07), 200, 340)
    if kind == "cry":
        for c in (L, R): d.rectangle([px(c) - lw // 2, px(ey + 0.03), px(c) + lw // 2, px(ey + 0.15)], fill=(120, 190, 255, 220))
    if kind in ("embarrassed", "happy", "smile", "laugh"):
        for c in (L - 0.025, R + 0.025): d.ellipse([px(c - 0.035), px(ey + 0.06), px(c + 0.035), px(ey + 0.105)], fill=BLUSH)
    return im.resize((1024, 1024), Image.LANCZOS)


if __name__ == "__main__":
    argv = sys.argv[1:]
    out = argv[0]
    names = argv[argv.index("--names") + 1].split(",") if "--names" in argv else NAMES
    os.makedirs(out, exist_ok=True)
    for n in names:
        k = KIND.get(n, "neutral")
        draw_face(k).save(os.path.join(out, n + ".png")); draw_face(k, talk=True).save(os.path.join(out, n + "_t.png"))
    print("wrote", len(names) * 2, "faces to", out)
