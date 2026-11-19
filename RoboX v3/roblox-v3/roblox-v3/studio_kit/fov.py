#!/usr/bin/env python
"""Ask Studio for each shot's vertical field of view (MT.shotFovs) and save <episode>/fov.json.
Run after load.py and before render.py --tiles 2/4 and tiles4k.py:   python fov.py --ep <episode>"""
import json, sys
import episode, rb

argv = sys.argv[1:]
ep = episode.ep_dir(argv)
r = rb.lua("return shared.MT.shotFovs()")
try:
    fov = json.loads(rb.text(r))
except ValueError:
    sys.exit("Studio did not return FOVs (run load.py first):\n" + rb.text(r)[:800])
missing = [s for s, _ in episode.shots(ep) if not fov.get(s)]
json.dump(fov, open(episode.path(ep, "fov.json"), "w"), indent=1)
print(f"fov.json: {len(fov)} shots" + (f"; NO FOV (shot failed to build or missing from MT.SHOTS): {' '.join(missing)}" if missing else ""))
