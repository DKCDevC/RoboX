#!/usr/bin/env python
"""The four stages of an episode build, each ending in something the user looks at and approves: CAST, SET, STORYBOARD, RENDER.

  python stage.py --ep <episode> init                       create <episode>/stage/ and stages.json from the templates
  python stage.py --ep <episode> status                     what exists, what is approved, what is next (+ storyboard pacing)
  python stage.py --ep <episode> approve cast|set|storyboard [--note "..."] [--force]
  python stage.py --ep <episode> revoke  cast|set|storyboard     (also revokes the stages after it)
  python stage.py sheet img1.jpg img2.jpg ... -o <episode>/stage/cast_sheet.jpg [--cols 4] [--h 480] [--crop916]    tile labelled images
  python stage_capture.py --ep <episode> cast|set|storyboard    capture the sheet from Studio by itself (needs the episode loaded)

Order: cast -> set -> storyboard -> render. A stage can only be approved when the one before it is, and when its files exist
(--force skips the file check, never the order). build_episode.py refuses to render an episode that has a stages.json until
all three are approved (--skip-gates overrides). Episodes without stages.json (E01-E03) only get a warning.

Files per stage (all inside the episode folder):
  cast        cast.md                      one row per character: role, age, outfit, hair, face set, voice (templates/cast.md)
              stage/cast*.jpg              the cast sheet: every character, front and 3/4, plus 3 key faces
  set         sets.md                      one row per location: look family, hue, rule object, signs (templates/sets.md)
              stage/set*.jpg               wide + two angles of every set, lit
  storyboard  shotlist.md, shots.json      one row per shot, times from words.json (templates/shot-list.md)
              stage/storyboard*.jpg        frame 1 (and the last frame) of every shot on the real cast and sets (checks.ps1)
"""
import datetime, glob, json, os, sys
import episode

STAGES = ["cast", "set", "storyboard"]
NEEDS = {
    "cast": [("cast.md", "cast.md"), ("stage/cast*.jpg", "a cast sheet (stage/cast_sheet.jpg)")],
    "set": [("sets.md", "sets.md"), ("stage/set*.jpg", "set sheets (stage/set_<name>.jpg)")],
    "storyboard": [("shotlist.md", "shotlist.md"), ("shots.json", "shots.json"), ("stage/storyboard*.jpg", "a storyboard sheet (stage/storyboard_01.jpg ...)")],
}


def _p(ep, rel):
    return os.path.join(ep, *rel.split("/"))


def _has(ep, pat):
    return bool(glob.glob(_p(ep, pat)))


def load(ep):
    f = os.path.join(ep, "stages.json")
    return json.load(open(f, encoding="utf-8")) if os.path.exists(f) else None


def save(ep, d):
    json.dump(d, open(os.path.join(ep, "stages.json"), "w", encoding="utf-8"), indent=1)


def missing(ep, stage):
    return [label for pat, label in NEEDS[stage] if not _has(ep, pat)]


def storyboard_pacing(ep):
    """Pacing of the planned cuts straight from shots.json (offline): look-reference.md numbers, fast read."""
    f = os.path.join(ep, "shots.json")
    if not os.path.exists(f):
        return []
    shots = [s for sc in json.load(open(f, encoding="utf-8")) for s in sc["shots"]]
    if len(shots) < 2:
        return []
    L = [s["end"] - s["t"] for s in shots]
    dur = shots[-1]["end"] - shots[0]["t"]
    mean = sum(L) / len(L)
    over = sum(x > 3.5 for x in L)
    short = sum(x < 1 for x in L) / len(L)
    rows = [
        ("shots", f"{len(L)} in {dur:.1f} s", True),
        ("cuts per 10 s 7-12", f"{(len(L) - 1) / dur * 10:.1f}", 7 <= (len(L) - 1) / dur * 10 <= 12),
        ("mean shot 1.0-1.5 s", f"{mean:.2f} s", 1.0 <= mean <= 1.5),
        ("shots over 3.5 s: at most 4, none over 6 s", f"{over} (longest {max(L):.1f} s)", over <= 4 and max(L) <= 6),
        ("shots under 1 s: 20-45 %", f"{short * 100:.0f} %", .20 <= short <= .45),
    ]
    return rows


def status(ep):
    d = load(ep)
    print(f"episode: {ep}")
    if d is None:
        print("  no stages.json: this episode predates the stage workflow (run: python stage.py --ep <episode> init)")
    prev_ok = True
    nxt = None
    for s in STAGES:
        miss = missing(ep, s)
        ap = (d or {}).get(s, {}).get("approved")
        mark = "APPROVED" if ap else ("ready for review" if not miss else "in progress")
        print(f"  [{'x' if ap else ' '}] {s:11s} {mark}" + (f"  ({ap[:10]}{', ' + d[s]['note'] if d[s].get('note') else ''})" if ap else ""))
        for m in miss:
            print(f"        missing: {m}")
        if not ap and nxt is None:
            nxt = s
    r_ok = os.path.exists(_p(ep, "out/final.mp4"))
    print(f"  [{'x' if r_ok else ' '}] render      {'out/final.mp4 exists' if r_ok else 'not rendered'}")
    pr = storyboard_pacing(ep)
    if pr:
        print("  storyboard pacing (from shots.json, fast read, look-reference.md section 4):")
        for n, v, ok in pr:
            print(f"    {'ok  ' if ok else 'WARN'} {n:45s} {v}")
    print("  next:", f"finish and approve {nxt}" if nxt else ("render: python build_episode.py --ep <episode>" if not r_ok else "edit and QA (pipeline.md steps 5-10)"))


def gate(ep):
    """(ok, message) for build_episode.py."""
    d = load(ep)
    if d is None:
        return True, "warning: no stages.json, so cast / set / storyboard approvals are not checked (python stage.py --ep <ep> init)"
    todo = [s for s in STAGES if not d.get(s, {}).get("approved")]
    if todo:
        return False, "not approved yet: " + ", ".join(todo) + ". Show the user the sheets in stage/, then: python stage.py --ep <ep> approve <stage> (or --skip-gates)"
    return True, "stages approved: " + ", ".join(STAGES)


def init(ep):
    os.makedirs(_p(ep, "stage"), exist_ok=True)
    tpl = os.path.abspath(os.path.join(episode.KIT, "..", "templates"))
    for name in ("cast.md", "sets.md"):
        dst = _p(ep, name)
        src = os.path.join(tpl, name)
        if not os.path.exists(dst) and os.path.exists(src):
            open(dst, "w", encoding="utf-8").write(open(src, encoding="utf-8").read())
            print("created", dst)
    if load(ep) is None:
        save(ep, {s: {"approved": None, "note": ""} for s in STAGES})
        print("created stages.json")
    status(ep)


def approve(ep, stage, note, force):
    d = load(ep) or {s: {"approved": None, "note": ""} for s in STAGES}
    i = STAGES.index(stage)
    if i and not d.get(STAGES[i - 1], {}).get("approved"):
        sys.exit(f"cannot approve {stage}: {STAGES[i - 1]} is not approved yet (order: cast, set, storyboard)")
    miss = missing(ep, stage)
    if miss and not force:
        sys.exit(f"cannot approve {stage}: missing " + "; ".join(miss) + " (--force skips this check)")
    d[stage] = {"approved": datetime.datetime.now().isoformat(timespec="seconds"), "note": note or ""}
    save(ep, d)
    print(f"{stage} approved")


def revoke(ep, stage):
    d = load(ep) or {}
    for s in STAGES[STAGES.index(stage):]:
        d[s] = {"approved": None, "note": ""}
    save(ep, d)
    print("revoked:", ", ".join(STAGES[STAGES.index(stage):]))


def tile(files, out, cols=4, th=480, crop916=False):
    """Tile images into one labelled sheet (label = file name without extension). crop916: centre-crop landscape captures to 9:16."""
    import cv2, numpy as np
    tiles = []
    for f in files:
        im = cv2.imread(f)
        if im is None:
            print("skip", f); continue
        if crop916:
            h, w = im.shape[:2]; cw = int(h * 9 / 16)
            if cw < w:
                x0 = (w - cw) // 2; im = im[:, x0:x0 + cw]
        w = max(1, int(im.shape[1] * th / im.shape[0]))
        im = cv2.resize(im, (w, th), interpolation=cv2.INTER_AREA)
        label = os.path.splitext(os.path.basename(f))[0]
        cv2.rectangle(im, (0, 0), (8 + 10 * len(label), 26), (0, 0, 0), -1)
        cv2.putText(im, label, (4, 19), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255, 255, 255), 1, cv2.LINE_AA)
        tiles.append(im)
    if not tiles:
        sys.exit("no images")
    rows = [np.hstack(tiles[i:i + cols]) for i in range(0, len(tiles), cols)]
    Wmax = max(r.shape[1] for r in rows)
    rows = [np.pad(r, ((0, 0), (0, Wmax - r.shape[1]), (0, 0))) for r in rows]
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    cv2.imwrite(out, np.vstack(rows), [cv2.IMWRITE_JPEG_QUALITY, 90])
    print(f"sheet of {len(tiles)} images -> {out}")


def sheet(argv):
    out = episode.pop_flag(argv, "-o") or sys.exit("sheet needs -o <out.jpg>")
    cols = int(episode.pop_flag(argv, "--cols", "4")); th = int(episode.pop_flag(argv, "--h", "480"))
    crop = bool(episode.pop_flag(argv, "--crop916", False, has_value=False))
    files = [f for a in argv for f in (sorted(glob.glob(a)) or [a])]
    tile(files, out, cols, th, crop)


if __name__ == "__main__":
    argv = sys.argv[1:]
    if argv and argv[0] == "sheet":
        sheet(argv[1:]); sys.exit()
    ep = episode.ep_dir(argv)
    note = episode.pop_flag(argv, "--note", "")
    force = bool(episode.pop_flag(argv, "--force", False, has_value=False))
    cmd = argv[0] if argv else "status"
    if cmd == "init": init(ep)
    elif cmd == "status": status(ep)
    elif cmd in ("approve", "revoke") and len(argv) > 1 and argv[1] in STAGES:
        approve(ep, argv[1], note, force) if cmd == "approve" else revoke(ep, argv[1])
    else:
        sys.exit(__doc__)
