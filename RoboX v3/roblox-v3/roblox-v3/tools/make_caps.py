#!/usr/bin/env python3
"""words.json -> caps.ass (1080x1920). Default = the v3.1 look (captions.md): one word per caption, white, normal capitalisation, y 1306, 84 px, 4 px outline, no key word.
The older look (lowercase, red ALL-CAPS key words, 1-2 words) is --lowercase with --accent/--sheet and --pair (legacy/captions-older-looks.md).
usage: python make_caps.py words.json caps.ass [--sheet script-sheet.md] [--accent "Chloe,bell"] [--hook-until 3.7]
       [--color E8452C] [--lead 0.033] [--y 1306] [--fs 84] [--outline 4] [--max-hold 0.25] [--lowercase]
--sheet (preferred): lights exactly the word in each row's `caption highlight` cell, inside that row only ("whole line"
        lights the row; "-" none), so a word that repeats elsewhere is not lit. Rows are matched to words.json in order.
--accent-at "31.0,97.7": lights the one word starting within 0.08 s of each time (one occurrence only).
--accent: lights every occurrence of the listed words (old way); --hook-until: every word before that time.
--max-hold: max seconds a caption stays on screen after a word finishes speaking (default 0.25 s; clears captions during pauses)."""
import json, re, argparse, os, sys

p = argparse.ArgumentParser()
p.add_argument("words"); p.add_argument("out")
p.add_argument("--accent", default=""); p.add_argument("--hook-until", type=float, default=0.0)
p.add_argument("--color", default="E8452C"); p.add_argument("--lead", type=float, default=1 / 30)
p.add_argument("--y", type=int, default=1306); p.add_argument("--fs", type=int, default=84)
p.add_argument("--outline", type=int, default=4); p.add_argument("--font", default="Poppins ExtraBold")
p.add_argument("--max-hold", type=float, default=0.25, help="Max hold after word end so pauses stay clean")
p.add_argument("--keep-case", action="store_true", help="(default now) keep the original word casing")
p.add_argument("--lowercase", action="store_true", help="older look: lowercase words, accent words in ALL CAPS")
p.add_argument("--pair", action="store_true", help="Smart 1-2 word v3 chunking (pairs short adjacent non-accent words <=12 chars)")
p.add_argument("--sheet"); p.add_argument("--accent-at", default="")
a = p.parse_args()

with open(a.words, encoding="utf-8-sig") as fh:
    d = json.load(fh)
if isinstance(d, dict):
    d = d.get("words") or [w for s in d.get("segments", []) for w in s.get("words", [])]
W = [(float(w["start"]), float(w["end"]), (w.get("word") or w.get("text") or "").strip()) for w in d]
W = [w for w in W if w[2]]
acc = {x.strip().lower() for x in a.accent.split(",") if x.strip()}
norm = lambda w: re.sub(r"'s$", "", re.sub(r"[^\w']", "", w).lower().replace("’", "'"))   # Jada's matches Jada
show = lambda w: re.sub(r"[\"“”,.;:]+", "", w) or w    # captions drop commas, full stops and quotes; keep ? ! and apostrophes
lit, hook_idx = set(), set()

for t in [float(x) for x in a.accent_at.split(",") if x.strip()]:
    j = min(range(len(W)), key=lambda k: abs(W[k][0] - t))
    if abs(W[j][0] - t) <= 0.08:
        lit.add(j)
    else:
        print(f"warning: no word starts near {t}")

if a.sheet:                                   # per-row highlights, aligned to the words in order
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from sheetlib import load
    Wn = [norm(w[2]) for w in W]; cur = 0
    for k, r in enumerate(x for x in load(a.sheet)["rows"] if x["kind"] == "line"):
        toks = [norm(t) for t in r["text"].split() if norm(t)]
        for j in range(cur, min(cur + 8, len(Wn))):            # re-sync on the row's first word
            if toks and Wn[j] == toks[0]:
                cur = j; break
        span = range(cur, min(cur + len(toks), len(Wn)))
        cell = re.sub(r"\(manual\)", "", r["hl"]).strip()
        if k == 0:
            hook_idx |= set(span)          # the hook = row 1, accented or not (same as script_check.py)
        if "whole" in cell.lower():
            lit |= set(span)
        elif cell and cell != "-":
            want = [norm(x) for x in cell.split()]
            for j in span:
                if Wn[j:j + len(want)] == want:
                    lit |= set(range(j, j + len(want))); break
            else:
                print(f"warning: highlight '{cell}' not found in row '{r['text'][:30]}'")
        cur += len(toks)


def bgr(hex6):
    hex6 = hex6.lstrip("#")
    r, g, b = hex6[0:2], hex6[2:4], hex6[4:6]
    return f"&H00{b}{g}{r}&"


def ts(t):
    t = max(0.0, t); h = int(t // 3600); m = int(t % 3600 // 60); s = t % 60
    return f"{h}:{m:02d}:{s:05.2f}"


hdr = f"""[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
WrapStyle: 2
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding
Style: Cap,{a.font},{a.fs},&H00FFFFFF&,&H00FFFFFF&,&H00000000&,&H00000000&,0,0,0,0,100,100,0,0,1,{a.outline},4,5,60,60,0,1

[Events]
Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
"""
ev, n_acc = [], 0
tokens = []
for i, (s, e, w) in enumerate(W):
    txt = show(w)
    hot = (s < a.hook_until) or (norm(w) in acc) or (i in lit)
    if a.lowercase:
        txt = txt.upper() if hot else txt.lower()
    raw_ends_sentence = w.rstrip().endswith((".", "!", "?"))
    tokens.append({"s": s, "e": e, "txt": txt, "hot": hot, "eos": raw_ends_sentence})

if a.pair:
    paired = []
    idx = 0
    while idx < len(tokens):
        cur = tokens[idx]
        if (
            idx + 1 < len(tokens)
            and not cur["hot"]
            and not tokens[idx + 1]["hot"]
            and not cur["eos"]
            and (tokens[idx + 1]["s"] - cur["e"]) < 0.15
            and (len(cur["txt"]) + 1 + len(tokens[idx + 1]["txt"])) <= 12
        ):
            nxt = tokens[idx + 1]
            paired.append({"s": cur["s"], "e": nxt["e"], "txt": cur["txt"] + " " + nxt["txt"], "hot": False, "eos": nxt["eos"]})
            idx += 2
        else:
            paired.append(cur)
            idx += 1
    tokens = paired

for i, tok in enumerate(tokens):
    s, e, txt, hot = tok["s"], tok["e"], tok["txt"], tok["hot"]
    start = max(0.0, s - a.lead)
    nxt = tokens[i + 1]["s"] - a.lead if i + 1 < len(tokens) else e + a.max_hold
    # Cap caption end at word_end + max_hold so words vanish cleanly during designed pauses
    end = max(min(nxt, e + a.max_hold), start + 0.10)
    scale = min(1.0, 0.80 * 1080 / max(1, len(txt) * 0.66 * a.fs))   # shrink long words to <=80% width
    n_acc += hot
    col = bgr(a.color) if hot else "&H00FFFFFF&"
    tags = (f"{{\\an5\\pos(540,{a.y})\\1c{col}\\bord{a.outline}\\xshad0\\yshad4\\blur1"
            f"\\fscx{125*scale:.0f}\\fscy{125*scale:.0f}\\t(0,133,\\fscx{100*scale:.0f}\\fscy{100*scale:.0f})}}")
    ev.append(f"Dialogue: 0,{ts(start)},{ts(end)},Cap,,0,0,0,,{tags}{txt}")

open(a.out, "w", encoding="utf-8").write(hdr + "\n".join(ev) + "\n")
hook = {i for i, w in enumerate(W) if w[0] < a.hook_until} | hook_idx
post = [i for i in range(len(W)) if i not in hook]
n_post = sum(1 for i in post if (W[i][0] < a.hook_until) or norm(W[i][2]) in acc or i in lit)
print(f"{len(ev)} captions, accent {n_acc} total; after the hook {n_post}/{len(post)} = {100*n_post/max(1,len(post)):.1f}% (ceiling 13 %) -> {a.out}")
