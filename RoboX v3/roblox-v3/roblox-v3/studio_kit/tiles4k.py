#!/usr/bin/env python
"""Plan 4K (2160x3840) tiles per shot from <episode>/fov.json and the capture size; writes tiles4k.json and tiles4k.lua
(shared.MT_TILES) into the episode. Each frame = R captures from one camera centre, pitched to rows; stitch.py --tiles 4
joins them. Then run load.py again (it loads tiles4k.lua) and render.py --tiles 4.

  python tiles4k.py --ep <episode> [--capture 1896x1040]

--capture is the size of one screen_capture image (check one: it depends on the Studio viewport)."""
import json, math, sys
import episode

argv = sys.argv[1:]
ep = episode.ep_dir(argv)
CW, CH = (int(x) for x in episode.pop_flag(argv, "--capture", "1896x1040").split("x"))
W, H = 2160, 3840
MARGIN = 1.6                 # degrees of overlap each side
plan = {}
for sid, V in json.load(open(episode.path(ep, "fov.json"))).items():
    if not V:
        continue
    fo = (H / 2) / math.tan(math.radians(V / 2))
    tx = (W / 2) / fo                                  # tan of output half width
    ft = (CW / 2) / (tx * 1.04)                        # tile focal so the width fits
    Ft = 2 * math.degrees(math.atan((CH / 2) / ft))    # tile vertical FOV
    rows = 3
    while Ft / 2 < V / (2 * rows) + MARGIN:
        rows += 1
    pitches = [V / 2 - (i + 0.5) * V / rows for i in range(rows)]
    plan[sid] = {"V": V, "rows": rows, "Ft": Ft, "p": pitches, "res": ft / fo}
json.dump(plan, open(episode.path(ep, "tiles4k.json"), "w"), indent=1)
lua = "shared.MT_TILES = {\n" + "".join(
    f'\t["{k}"] = {{ rows = {v["rows"]}, Ft = {v["Ft"]:.5f}, p = {{ {", ".join(f"{x:.5f}" for x in v["p"])} }} }},\n'
    for k, v in sorted(plan.items())) + "}\nreturn 'tiles ok'"
open(episode.path(ep, "tiles4k.lua"), "w").write(lua)
rs = [v["rows"] for v in plan.values()]; res = [v["res"] for v in plan.values()]
print("rows", min(rs), max(rs), "captures/frame avg", round(sum(rs) / len(rs), 2), "res vs native 4K", round(min(res), 2), round(max(res), 2))
