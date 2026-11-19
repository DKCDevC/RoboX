"""Where an episode lives, shared by load.py, fov.py, render.py, stitch.py, tiles4k.py and join.py.

Pick the episode folder with --ep <folder> on any script, or the RBX_EP environment variable, or put the path in
studio_kit/episode.txt (one line). Layout inside the episode folder:

  shots.json            [{"scene": "S1", "shots": [{"id": "s001", "t": 0.0, "end": 1.1}, ...]}, ...]  (times in seconds)
  lua/                  episode Luau loaded after the kit: faces.lua / cloth.lua (optional, your own uploaded ids),
                        then every other *.lua in name order (shots.lua must fill shared.MT.SHOTS)
  audio/vo.wav          optional voice; audio/music.mp3 optional bed (join.py mixes them)
  fov.json, tiles4k.*   written by fov.py / tiles4k.py
  frames/raw1|raw2|raw4/<id>/   captures (render.py)      frames/hd|4k/<id>/  stitched frames (stitch.py)
  out/                  picture.mp4, final.mp4 (join.py)

A copy of studio_kit/episode_template/ is a working two-shot episode to start from.
"""
import json, os, sys

KIT = os.path.dirname(os.path.abspath(__file__))
FPS = 30


def pop_flag(argv, name, default=None, has_value=True):
    """Remove --name [value] from argv and return the value (or True for a bare flag)."""
    if name not in argv:
        return default
    i = argv.index(name)
    if not has_value:
        del argv[i]
        return True
    if i + 1 >= len(argv):
        sys.exit(f"{name} needs a value")
    v = argv[i + 1]
    del argv[i:i + 2]
    return v


def ep_dir(argv):
    d = pop_flag(argv, "--ep") or os.environ.get("RBX_EP")
    if not d:
        f = os.path.join(KIT, "episode.txt")
        if os.path.exists(f):
            d = open(f, encoding="utf-8-sig").read().strip()
    if not d:
        sys.exit("No episode: pass --ep <folder>, set RBX_EP, or write the folder into studio_kit/episode.txt")
    d = os.path.abspath(os.path.expanduser(d))
    if not os.path.isfile(os.path.join(d, "shots.json")):
        sys.exit(f"{d} has no shots.json (see episode_template/)")
    return d


def shots(ep):
    """Ordered list of (id, frame_count) from shots.json."""
    out = []
    for sc in json.load(open(os.path.join(ep, "shots.json"), encoding="utf-8")):
        for s in sc["shots"]:
            out.append((s["id"], max(8, round(s["end"] * FPS) - round(s["t"] * FPS))))
    return out


def pick(ep, ids):
    """Shot ids from the command line; 'all' or nothing = every shot. Unknown ids stop the script."""
    allshots = shots(ep)
    known = dict(allshots)
    if not ids or ids == ["all"]:
        return allshots
    bad = [i for i in ids if i not in known]
    if bad:
        sys.exit("unknown shot ids: " + " ".join(bad))
    return [(i, known[i]) for i in ids]


def path(ep, *parts, make=False):
    p = os.path.join(ep, *parts)
    if make:
        os.makedirs(p if not os.path.splitext(p)[1] else os.path.dirname(p), exist_ok=True)
    return p
