# Episode template

Copy this folder anywhere (e.g. `<project>/projects/ep01/`), then point the kit at it with `--ep <folder>` (or `RBX_EP`, or `studio_kit/episode.txt`).

- `shots.json`: shot ids and times (seconds, from the voice's word timestamps). Frame count = (end − t) × 30.
- `lua/shots.lua`: one `MT.SHOTS[id]` per shot: `build()` makes the set and cast and returns the camera `{ loc, look, lens }` in shot coordinates (x right, y forward, z up); `act(f, n, t)` moves people per frame.
- Optional `lua/faces.lua` / `lua/cloth.lua`: your own uploaded face and clothing ids (`shared.MT_FACES`, `shared.MT_CLOTH`).
- Optional `audio/vo.wav`, `audio/music.mp3`, `fonts/`.

Run, from `studio_kit/` with Studio open and `start_bridge.bat` running:

```
python load.py --ep <folder>
python fov.py --ep <folder>
python render.py --ep <folder>            (wait until bridge.log shows the jobs done)
python stitch.py --ep <folder>
python join.py --ep <folder>              -> <folder>/out/picture.mp4 (and final.mp4 with audio/vo.wav)
```
