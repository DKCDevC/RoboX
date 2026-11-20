# Episode template

Copy this folder anywhere (e.g. `<project>/projects/ep01/`), then point the kit at it with `--ep <folder>` (or `RBX_EP`, or `studio_kit/episode.txt`).

- `shots.json`: shot ids and times (seconds, from the voice's word timestamps). Frame count = (end − t) × 30.
- `lua/shots.lua`: one `MT.SHOTS[id]` per shot: `build()` makes the set and cast and returns the camera `{ loc, look, lens }` in shot coordinates (x right, y forward, z up); `act(f, n, t)` moves people per frame.
- Optional `lua/faces.lua` / `lua/cloth.lua`: your own uploaded face and clothing ids (`shared.MT_FACES`, `shared.MT_CLOTH`).
- Optional `audio/vo.wav`, `audio/music.mp3`, `fonts/`.
- The four-stage workflow (cast, set, storyboard, render; `pipeline.md` Step 3): run `python stage.py --ep <folder> init` first. It creates `stage/` (the sheets the user approves), `cast.md`, `sets.md` and `stages.json`. Split the episode Luau into `lua/cast.lua`, `lua/sets.lua`, `lua/shots.lua` (they load in name order, after `faces.lua` / `cloth.lua`), so each stage has its own file to change. `build_episode.py` will not render until `stage.py approve cast`, `approve set` and `approve storyboard` are done.

Run, from `studio_kit/` with Studio open and `start_bridge.bat` running:

```
python load.py --ep <folder>
python fov.py --ep <folder>
python render.py --ep <folder>            (wait until bridge.log shows the jobs done)
python stitch.py --ep <folder>
python join.py --ep <folder>              -> <folder>/out/picture.mp4 (and final.mp4 with audio/vo.wav)
```

- Look kit (v3.2): `lib15_world.lua` (exteriors), `lib16_rooms.lua` (interiors), art grade `MT.ART` and `MT.portraitLight` in `lib11.lua`, `make_faces_gneef.py` + `make_hero_clothes.py` + `fabricize.py` (hero faces and clothes), `spec.headScale` / `spec.hairScale` in `lib10.lua`.
