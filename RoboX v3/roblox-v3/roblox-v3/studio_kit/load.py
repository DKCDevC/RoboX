#!/usr/bin/env python
"""Load the MT kit and an episode into Roblox Studio, in the one order that works (the bridge must be running).

  python load.py --ep <episode>          kit + episode
  python load.py --kit                   kit only (no episode: e.g. after Studio restarted, before inserting assets)

Order: faces.lua -> [episode lua/faces.lua] -> lib.lua -> lib2 -> lib3 -> hair.lua -> lib4 -> lib5 -> lib6 ->
       [episode lua/cloth.lua] -> lib7 -> lib8 -> lib9 -> lib10 -> [episode tiles4k.lua] -> every other episode lua/*.lua by name.
Why: lib6 preloads shared.MT_FACES and lib7 reads shared.MT_CLOTH when they load, so your own face and clothing ids
(faces.lua / cloth.lua in the episode) must come before them; each libN wraps functions of the ones before it.
Your shot definitions (MT.SHOTS) go in the episode's lua/ folder, e.g. lua/shots.lua. Stops at the first error."""
import os, sys
import episode, rb

KIT_ORDER = ["faces.lua", "@faces.lua", "lib.lua", "lib2.lua", "lib3.lua", "hair.lua", "lib4.lua", "lib5.lua", "lib6.lua",
             "@cloth.lua", "lib7.lua", "lib8.lua", "lib9.lua", "lib10.lua", "@@tiles4k.lua"]

argv = sys.argv[1:]
kit_only = bool(episode.pop_flag(argv, "--kit", False, has_value=False))
ep = None if kit_only else episode.ep_dir(argv)
files = []
for name in KIT_ORDER:
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
    extra = sorted(f for f in os.listdir(lua_dir) if f.endswith(".lua") and f not in ("faces.lua", "cloth.lua")) if os.path.isdir(lua_dir) else []
    if not extra:
        print("warning: the episode has no lua/*.lua with shot definitions (MT.SHOTS)")
    files += [os.path.join(lua_dir, f) for f in extra]

rb.sid = rb.studio_id()
for p in files:
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
