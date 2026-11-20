#!/usr/bin/env python
"""Capture the sheets of the stage workflow from Roblox Studio by itself (pipeline.md Step 3).

  python stage_capture.py --ep <episode> cast        cast_<name>_front / _three / _face_<face> previews -> stage/cast_sheet.jpg
  python stage_capture.py --ep <episode> set         set_<name>_wide / _low / _top previews              -> stage/set_sheet.jpg
  python stage_capture.py --ep <episode> storyboard  frame 1, the middle and the last frame of every shot            -> stage/storyboard_01.jpg ...
  python stage_capture.py --ep <episode> all         the three above
  [--ids s01,s02]  only these shots / previews        [--per 24]  tiles per storyboard sheet

Needs Studio open in Edit mode with the bridge running, and the episode loaded (python load.py --ep <episode>). The previews come from
the episode's Luau: MT.castPreview / MT.setPreview in lua/cast.lua and lua/sets.lua (lib11.lua). Each capture is a landscape
Studio capture, centre-cropped to the 9:16 band the final frame shows. Single tiles go to stage/tiles/, the sheets to stage/.
Same preflight as render.py: window shown and maximised, mouse off the 3D view, Edit mode, capture not blank."""
import json, os, sys
import cv2
import episode, preflight, rb, stage


def lua_ids():
    code = 'return shared.MT and shared.MT.listPreviews and shared.MT.listPreviews() or "NOT_LOADED"'
    r = rb.text(rb.lua(code)).strip()
    if "NOT_LOADED" in r:
        sys.exit("the kit or the episode is not loaded in Studio. Run: python load.py --ep <episode>")
    return [x for x in r.split(",") if x]


def shot_list(ep):
    f = episode.path(ep, "shots.json")
    return [(s["id"], max(1, int(round((s["end"] - s["t"]) * episode.FPS)))) for sc in json.load(open(f, encoding="utf-8")) for s in sc["shots"]]


def grab(sid, shot, frame, path, wait=1.0):
    """Pose the scene at (shot, frame) and capture it to path."""
    code = f'''shared.MT.roll = 0
local ok, e = pcall(function() shared.MT.cur = nil; shared.MT.frame("{shot}", {frame}) end)
task.wait({wait})
return ok and "ok" or ("ERR " .. tostring(e))'''
    r = rb.text(rb.lua(code)).strip()
    if not r.startswith("ok"):
        print(f"  {shot} frame {frame}: {r[:200]}")
        return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    rb.send({"name": "screen_capture", "arguments": {"capture_id": "ScreenCapture_1", "studio_id": sid}, "save": path})
    im = cv2.imread(path)
    if im is None or float(im.std()) < 6:
        print(f"  {shot} frame {frame}: blank or missing capture (window hidden? mouse over the view?)")
        return False
    return True


def tiles_for(ep, sid, ids, tag, label=lambda i: i):
    out = []
    for i in ids:
        raw = episode.path(ep, "stage", "raw", f"{label(i)}.png")
        if grab(sid, i, 1, raw):
            out.append(raw)
    return out


def do_cast_or_set(ep, sid, kind, only):
    if kind == "cast":     # a new place has an empty MTLib: insert the hairs the cast needs first (ins.py --missing)
        import ins
        ins.ensure_cast_hairs()
    ids = [i for i in lua_ids() if i.startswith(kind + "_") and (not only or i in only)]
    if not ids:
        sys.exit(f"no {kind}_* previews registered: add MT.{'castPreview' if kind == 'cast' else 'setPreview'}(...) to the episode's lua/{kind}s.lua")
    print(f"{kind}: {len(ids)} previews")
    files = tiles_for(ep, sid, ids, kind)
    out = episode.path(ep, "stage", f"{kind}_sheet.jpg")
    stage.tile(files, out, cols=6 if kind == "cast" else 3, th=520, crop916=True)


def do_storyboard(ep, sid, only, per):
    shots = [(i, n) for i, n in shot_list(ep) if not only or i in only]
    print(f"storyboard: {len(shots)} shots")
    pairs = []
    for i, n in shots:
        got = []
        for tag, fr in (("a", 1), ("m", (n + 1) // 2), ("b", n)):     # first, middle and last frame
            if tag != "a" and (n < 12 or fr == 1): continue
            path = episode.path(ep, "stage", "raw", f"{i}_{tag}.png")
            if grab(sid, i, fr, path): got.append(path)
        pairs += got
    for k in range(0, len(pairs), per):
        stage.tile(pairs[k:k + per], episode.path(ep, "stage", f"storyboard_{k // per + 1:02d}.jpg"), cols=6, th=420, crop916=True)


if __name__ == "__main__":
    argv = sys.argv[1:]
    ep = episode.ep_dir(argv)
    only = episode.pop_flag(argv, "--ids"); only = set(only.split(",")) if only else None
    per = int(episode.pop_flag(argv, "--per", "24"))
    what = argv[0] if argv else sys.exit(__doc__)
    if what not in ("cast", "set", "storyboard", "all"):
        sys.exit(__doc__)
    ss = rb.studios()
    if not ss:
        sys.exit("no Studio answered. Open Studio with the place, turn on 'Enable Studio as MCP server', run start_bridge.bat")
    sid = ss[0]["id"] if len(ss) == 1 else (open(rb.SID_F, encoding="utf-8-sig").read().strip() if os.path.exists(rb.SID_F) else ss[0]["id"])
    rb.sid = sid
    if "Current Studio Mode: Edit" not in (next((s for s in ss if s["id"] == sid), ss[0]).get("state") or ""):
        sys.exit("Studio is not in Edit mode (Play/Run is on)")
    print(preflight.place_window(fix=True))
    for w in (["cast", "set", "storyboard"] if what == "all" else [what]):
        if w == "storyboard": do_storyboard(ep, sid, only, per)
        else: do_cast_or_set(ep, sid, w, only)
    print("done. Look at", episode.path(ep, "stage"), "then: python stage.py --ep <episode> status")
