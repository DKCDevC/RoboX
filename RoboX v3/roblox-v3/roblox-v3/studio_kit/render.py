#!/usr/bin/env python
"""Queue shots for capture in Roblox Studio (the bridge must be running).

  python render.py --ep <episode> [--tiles 2] [--force] [--n 12] [all | s001 s002 ...]

--tiles 2 (default) 1080x1920: each frame is captured twice (camera pitched up and down), stitch.py joins them.
--tiles 4          2160x3840: R pitched rows per frame from tiles4k.json (run tiles4k.py first), stitch.py --tiles 4.
--tiles 1          one landscape capture per frame: quick previews only; join.py would crop it to 9:16 (blurry, never ship).
--n N              only the first N frames of each shot (framing tests).  --force re-captures frames that exist.
--wait S           seconds Studio gets to draw a frame before its capture (default 0.12; at 0.03 tiles came out one
                   pose behind on 2026-11-19 and the stitched frames showed a doubled band). Raise it if seams double.
Captures land in <episode>/frames/raw<tiles>/<id>/NNNNN.png. Watch progress in bridge.log / render_progress.txt."""
import json, os, sys, time
import episode, rb

argv = sys.argv[1:]
ep = episode.ep_dir(argv)
tiles = int(episode.pop_flag(argv, "--tiles", "2"))
force = bool(episode.pop_flag(argv, "--force", False, has_value=False))
wait = float(episode.pop_flag(argv, "--wait", "0.12"))
lim = episode.pop_flag(argv, "--n")
lim = int(lim) if lim else None
if tiles not in (1, 2, 4):
    sys.exit("--tiles is 1, 2 or 4")
todo = episode.pick(ep, argv)
sid = rb.studio_id()

FN = {1: "frame", 2: "frameTile", 4: "frameTileN"}[tiles]
rows = {}
if tiles == 4:
    tf = episode.path(ep, "tiles4k.json")
    if not os.path.exists(tf):
        sys.exit("no tiles4k.json: run fov.py then tiles4k.py, then load.py again (it loads tiles4k.lua)")
    rows = {k: v["rows"] for k, v in json.load(open(tf)).items()}
TEMPLATE = '''local F = {{F}}
local ok, e = pcall(function() shared.MT.%s("%s", F) end)
if F <= %d then task.wait(0.6) else task.wait(%s) end
if not ok then error(e) end
return "ok"'''
caps = 0
for k, (shot, n) in enumerate(todo):
    n = min(n, lim) if lim else n
    per = tiles if tiles < 4 else rows[shot]
    out = episode.path(ep, "frames", f"raw{tiles}", shot, make=True)
    job = {"render": {"tool": "execute_luau", "code_arg": "code", "args": {"datamodel_type": "Edit", "studio_id": sid},
                      "template": TEMPLATE % (FN, shot, per, wait), "frames": [1, per * n], "force": force,
                      "capture": {"name": "screen_capture", "arguments": {"capture_id": "ScreenCapture_1", "studio_id": sid}},
                      "out": out}}
    name = f"{int(time.time()*1000)+k}_{shot}.json"
    tmp = os.path.join(rb.HERE, "queue", name + ".tmp")
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(job, fh)
    os.replace(tmp, os.path.join(rb.HERE, "queue", name))
    caps += per * n
print(f"queued {len(todo)} shots, {caps} captures (about {caps * 1.2 / 60:.0f} min at 1.2 s each) -> {episode.path(ep, 'frames', f'raw{tiles}')}")
