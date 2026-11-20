#!/usr/bin/env python
"""Queue shots for capture in Roblox Studio (the bridge must be running).

  python render.py --ep <episode> [--tiles 2] [--step 1|2] [--force] [--n 12] [all | s001 s002 ...]
  python render.py --resume [--ep <episode>] [--no-preflight]

--tiles 2 (default) 1080x1920: each frame is captured twice (camera pitched up and down), stitch.py joins them.
--tiles 4          2160x3840: R pitched rows per frame from tiles4k.json (run tiles4k.py first), stitch.py --tiles 4.
--tiles 1          one landscape capture per frame: quick previews only; join.py would crop it to 9:16 (blurry, never ship).
--step N           render every Nth frame (default 1 = 30fps; --step 2 = 15fps "on twos", ~2x faster render;
                   stitch.py --step 2 fills the skipped frames cleanly so join.py still outputs 30fps).
--resume           resume jobs parked in queue_hold/ after an interruption (refreshes studio_id if Studio restarted).
--retries N        per-frame retry attempts in bridge.mjs before counting an error (default 3).
--n N              only the first N frames of each shot (framing tests).  --force re-captures frames that exist.
--wait S           seconds Studio gets to draw a frame before its capture (default 0.12; at 0.03 tiles came out one
                   pose behind on 2026-11-19 and the stitched frames showed a doubled band). Raise it if seams double.
Captures land in <episode>/frames/raw<tiles>/<id>/NNNNN.png. Watch progress in bridge.log / render_progress.txt."""
import json, os, shutil, sys, time
import episode, preflight, rb

argv = sys.argv[1:]
resume = bool(episode.pop_flag(argv, "--resume", False, has_value=False))
tiles = int(episode.pop_flag(argv, "--tiles", "2"))
step = int(episode.pop_flag(argv, "--step", "1"))
retries = int(episode.pop_flag(argv, "--retries", "3"))
force = bool(episode.pop_flag(argv, "--force", False, has_value=False))
wait = float(episode.pop_flag(argv, "--wait", "0.12"))
lim = episode.pop_flag(argv, "--n")
lim = int(lim) if lim else None
skip_pre = bool(episode.pop_flag(argv, "--no-preflight", False, has_value=False))
accept_size = bool(episode.pop_flag(argv, "--accept-size", False, has_value=False))
no_fix = bool(episode.pop_flag(argv, "--no-fix", False, has_value=False))

held = os.path.join(rb.HERE, "queue_hold")
stopped = os.path.join(rb.HERE, "render_stopped.txt")

if resume:
    if not os.path.isdir(held) or not [f for f in os.listdir(held) if f.endswith(".json")]:
        sys.exit("nothing to resume: queue_hold/ is empty")
    if os.path.exists(stopped):
        print("resuming after stop:", open(stopped).read().strip())
        os.remove(stopped)
    if not skip_pre:
        try:
            ep = episode.ep_dir(argv)
            preflight.run(ep, None, accept_size, fix=not no_fix)
        except SystemExit:
            if not no_fix:
                preflight.place_window(fix=True)
    sid = rb.studio_id()
    qdir = os.path.join(rb.HERE, "queue")
    os.makedirs(qdir, exist_ok=True)
    files = sorted(f for f in os.listdir(held) if f.endswith(".json"))
    for f in files:
        p = os.path.join(held, f)
        job = json.load(open(p, encoding="utf-8"))
        # Refresh studio_id in case Studio restarted
        if "render" in job:
            job["render"].setdefault("args", {})["studio_id"] = sid
            job["render"].setdefault("capture", {}).setdefault("arguments", {})["studio_id"] = sid
        tmp = os.path.join(qdir, f + ".tmp")
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(job, fh)
        os.replace(tmp, os.path.join(qdir, f))
        os.remove(p)
    print(f"resumed {len(files)} job(s) from queue_hold/ -> queue/ (existing frames will be skipped automatically)")
    sys.exit(0)

ep = episode.ep_dir(argv)
if tiles not in (1, 2, 4):
    sys.exit("--tiles is 1, 2 or 4")
if step < 1:
    sys.exit("--step must be >= 1")
todo = episode.pick(ep, argv)
if os.path.isdir(held) and os.listdir(held):
    print(f"note: {len(os.listdir(held))} job(s) parked in queue_hold/ are discarded (pass --resume next time to continue them)")
    shutil.rmtree(held, ignore_errors=True)
if os.path.exists(stopped):
    print("last render was stopped by the bridge:", open(stopped).read().strip()); os.remove(stopped)
if not skip_pre:
    preflight.run(ep, todo[0][0], accept_size, fix=not no_fix)
sid = rb.studio_id()

FN = {1: "frame", 2: "frameTile", 4: "frameTileN"}[tiles]
rows = {}
if tiles == 4:
    tf = episode.path(ep, "tiles4k.json")
    if not os.path.exists(tf):
        sys.exit("no tiles4k.json: run fov.py then tiles4k.py, then load.py again (it loads tiles4k.lua)")
    rows = {k: v["rows"] for k, v in json.load(open(tf)).items()}

# Only wait longer (0.5s) on the very first capture of a shot (F == 1, where MT.build runs);
# remaining tiles of frame 1 only pitch the camera and don't rebuild the scene.
TEMPLATE = '''local F = {{F}}
local ok, e = pcall(function() shared.MT.%s("%s", F) end)
if F == 1 then task.wait(0.5) else task.wait(%s) end
if not ok then error(e) end
return "ok"'''

caps = 0
for k, (shot, n) in enumerate(todo):
    n = min(n, lim) if lim else n
    per = tiles if tiles < 4 else rows[shot]
    out = episode.path(ep, "frames", f"raw{tiles}", shot, make=True)
    render_spec = {
        "tool": "execute_luau",
        "code_arg": "code",
        "args": {"datamodel_type": "Edit", "studio_id": sid},
        "template": TEMPLATE % (FN, shot, wait),
        "frames": [1, per * n],
        "force": force,
        "retries": retries,
        "capture": {"name": "screen_capture", "arguments": {"capture_id": "ScreenCapture_1", "studio_id": sid}},
        "out": out,
    }
    if step > 1:
        # Capture all tiles for frames 1, 1+step, 1+2*step, ... plus the final frame n
        anim_frames = list(range(1, n + 1, step))
        if anim_frames[-1] != n:
            anim_frames.append(n)
        indices = []
        for af in anim_frames:
            base = (af - 1) * per
            for t_idx in range(1, per + 1):
                indices.append(base + t_idx)
        render_spec["frameIndices"] = indices
        caps += len(indices)
    else:
        caps += per * n

    job = {"render": render_spec}
    name = f"{int(time.time()*1000)+k}_{shot}.json"
    tmp = os.path.join(rb.HERE, "queue", name + ".tmp")
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(job, fh)
    os.replace(tmp, os.path.join(rb.HERE, "queue", name))

step_note = f" (step={step}, ~{step}x faster; use stitch.py --step {step})" if step > 1 else ""
print(f"queued {len(todo)} shots, {caps} captures{step_note} (about {caps * 1.0 / 60:.0f} min) -> {episode.path(ep, 'frames', f'raw{tiles}')}")
