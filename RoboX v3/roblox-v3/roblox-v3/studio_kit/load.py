#!/usr/bin/env python
"""Load the MT kit and an episode into Roblox Studio, in the one order that works (the bridge must be running).

  python load.py --ep <episode>          kit + episode
  python load.py --kit                   kit only (no episode: e.g. after Studio restarted, before inserting assets)

Order: faces.lua -> [episode lua/faces.lua] -> lib.lua -> lib2 -> lib3 -> hair.lua -> lib4 -> lib5 -> lib6 ->
       [episode lua/cloth.lua] -> lib7 -> lib8 -> lib9 -> lib10 -> lib11 -> [episode tiles4k.lua] ->
       shared.MT.N (frame count per shot, made here from shots.json) -> every other episode lua/*.lua by name.
Why: lib6 preloads shared.MT_FACES and lib7 reads shared.MT_CLOTH when they load, so your own face and clothing ids
(faces.lua / cloth.lua in the episode) must come before them; each libN wraps functions of the ones before it.
Your shot definitions (MT.SHOTS) go in the episode's lua/ folder, e.g. lua/shots.lua. Stops at the first error."""
import json, os, sys
import episode, rb

KIT_ORDER = ["faces.lua", "@faces.lua", "lib.lua", "lib2.lua", "lib3.lua", "hair.lua", "lib4.lua", "lib5.lua", "lib6.lua",
             "@cloth.lua", "lib7.lua", "lib8.lua", "lib9.lua", "lib10.lua", "lib11.lua", "lib12.lua", "lib13_sets.lua",
             "lib14_cam.lua", "@anims.lua", "@@tiles4k.lua", "@@frames", "@@lipsync"]


def build_lipsync_lua(ep):
    wf = episode.path(ep, "words.json")
    sf = episode.path(ep, "shots.json")
    if not (os.path.exists(wf) and os.path.exists(sf)):
        return None
    wdata = json.load(open(wf, encoding="utf-8-sig"))
    words = wdata.get("words", wdata) if isinstance(wdata, dict) else wdata
    if not words:
        return None
    sdata = json.load(open(sf, encoding="utf-8-sig"))
    fps = episode.FPS
    lines = []
    for sc in sdata:
        for s in sc["shots"]:
            sid = s["id"]
            t0 = float(s["t"])
            n = max(8, round(float(s["end"]) * fps) - round(t0 * fps))
            bits = []
            for f in range(1, n + 1):
                gt = t0 + (f - 1) / fps
                speaking = False
                for w in words:
                    ws = float(w.get("start", 0))
                    we = float(w.get("end", 0))
                    if ws <= gt <= we:
                        # Short word: open throughout; longer multi-syllable word: articulate every ~4 frames
                        if (we - ws) < 0.16:
                            speaking = True
                        else:
                            speaking = (int((gt - ws) * fps / 4) % 2 == 0)
                        break
                bits.append("1" if speaking else "0")
            lines.append(f'\t["{sid}"] = "{"".join(bits)}",\n')
    return "shared.MT.LIPSYNC = {\n" + "".join(lines) + "}\nreturn 'lipsync: %d shots'" % len(lines)

argv = sys.argv[1:]
kit_only = bool(episode.pop_flag(argv, "--kit", False, has_value=False))
ep = None if kit_only else episode.ep_dir(argv)
files = []
for name in KIT_ORDER:
    if name == "@@frames":
        if ep:
            shots = episode.shots(ep)
            lines = "".join(f'\t["{sid}"] = {n},\n' for sid, n in shots)
            files.append(("frames", "shared.MT.N = {\n" + lines + "}\nreturn 'frames: %d'" % sum(n for _, n in shots)))
        continue
    if name == "@@lipsync":
        if ep:
            lip = build_lipsync_lua(ep)
            if lip:
                files.append(("lipsync", lip))
        continue
    if name.startswith("@@"):
        p = ep and episode.path(ep, name[2:])
    elif name.startswith("@"):
        p = ep and episode.path(ep, "lua", name[1:])
    else:
        p = os.path.join(episode.KIT, name)
    if p and os.path.exists(p):
        files.append(p)
if ep:
    lua_dir = episode.path(ep, "lua")
    extra = sorted(f for f in os.listdir(lua_dir) if f.endswith(".lua") and f not in ("faces.lua", "cloth.lua", "anims.lua", "00_frames.lua")) if os.path.isdir(lua_dir) else []
    if not extra:
        print("warning: the episode has no lua/*.lua with shot definitions (MT.SHOTS)")
    files += [os.path.join(lua_dir, f) for f in extra]

rb.sid = rb.studio_id()
for p in files:
    if isinstance(p, tuple):                       # generated code: (label, source)
        label, code = p
        r = rb.lua(code); t = rb.text(r).strip().replace("\n", " ")
        print(f"ok   gen/{label:18s} {t[:110]}"); continue
    code = open(p, encoding="utf-8-sig").read()
    r = rb.lua(code)
    t = rb.text(r).strip().replace("\n", " ")
    bad = "error" in r or (isinstance(r.get("res"), dict) and r["res"].get("result", {}).get("isError"))
    label = ("kit/" + os.path.basename(p)) if os.path.dirname(p) == episode.KIT else ("ep/" + os.path.relpath(p, ep))
    print(f"{'FAIL' if bad else 'ok  '} {label:22s} {t[:110]}")
    if bad:
        sys.exit(1)
if ep:
    r = rb.lua("local n = 0 for _ in pairs(shared.MT.SHOTS or {}) do n += 1 end return n")
    print("MT.SHOTS:", rb.text(r).strip(), "shots loaded;", len(episode.shots(ep)), "in shots.json")
