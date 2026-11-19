#!/usr/bin/env python
"""Send one job to the Roblox bridge and wait for the result.
  python rb.py call <tool> '<json args>' [save.png]
  python rb.py lua <file.lua> [Edit|Client|Server]      run a Luau file in Studio
  python rb.py cap <save.png> [x,y,z lx,ly,lz]           screen capture (optionally from a camera position, looking at a point)
  python rb.py studios                                  list open Studios and remember the only one in studio_id.txt
The Studio id comes from studio_id.txt; when it is missing or stale and exactly one Studio is open, it is filled in."""
import json, os, sys, time
HERE = os.path.dirname(os.path.abspath(__file__))
SID_F = os.path.join(HERE, "studio_id.txt")


def send(job, timeout=170):
    os.makedirs(os.path.join(HERE, "queue"), exist_ok=True)
    name = f"{int(time.time()*1000)}.json"
    tmp = os.path.join(HERE, "queue", name + ".tmp")
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(job, fh)
    os.replace(tmp, os.path.join(HERE, "queue", name))
    d = os.path.join(HERE, "done", name); t0 = time.time()
    while not os.path.exists(d):
        if time.time() - t0 > timeout: return {"error": "no answer from bridge (is start_bridge.bat running?)"}
        time.sleep(0.25)
    for _ in range(40):
        time.sleep(0.15)
        try:
            with open(d, encoding="utf-8") as fh: return json.load(fh)
        except (ValueError, PermissionError): pass
    with open(d, encoding="utf-8") as fh: return json.load(fh)


def text(r):
    res = r.get("res", r)
    if isinstance(res, dict) and "result" in res:
        return "\n".join(c.get("text", str(c)) for c in res["result"].get("content", []))
    return json.dumps(res)[:3000]


def studios():
    try:
        return json.loads(text(send({"name": "list_roblox_studios", "arguments": {}}, timeout=30))).get("studios", [])
    except (ValueError, AttributeError):
        return []


def studio_id():
    sid = open(SID_F, encoding="utf-8-sig").read().strip() if os.path.exists(SID_F) else ""
    open_ids = [s["id"] for s in studios()]
    if sid in open_ids or (sid and not open_ids):
        return sid      # an empty list also comes back while the bridge is busy rendering: keep the saved id
    if len(open_ids) == 1:
        open(SID_F, "w").write(open_ids[0])
        return open_ids[0]
    sys.exit(f"Studio id: {len(open_ids)} Studios open; write the right id into studio_id.txt (python rb.py studios)")


sid = None   # filled on first use by callers: rb.sid = rb.studio_id()


def lua(code, mode="Edit", timeout=170):
    global sid
    sid = sid or studio_id()
    return send({"name": "execute_luau", "arguments": {"code": code, "datamodel_type": mode, "studio_id": sid}}, timeout)


if __name__ == "__main__":
    m = sys.argv[1]
    if m == "studios":
        ss = studios(); print(json.dumps(ss, indent=1))
        if len(ss) == 1: open(SID_F, "w").write(ss[0]["id"]); print("saved", ss[0]["id"])
        sys.exit()
    sid = studio_id()
    if m == "call":
        args = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
        if sys.argv[2] != "list_roblox_studios": args.setdefault("studio_id", sid)
        job = {"name": sys.argv[2], "arguments": args}
        if len(sys.argv) > 4: job["save"] = sys.argv[4]
        r = send(job)
    elif m == "lua":
        with open(sys.argv[2], encoding="utf-8-sig") as fh:
            code = fh.read()
        r = lua(code, sys.argv[3] if len(sys.argv) > 3 else "Edit")
    elif m == "cap":
        args = {"capture_id": "ScreenCapture_1", "studio_id": sid}
        if len(sys.argv) > 4:
            args["camera_position"] = [float(x) for x in sys.argv[3].split(",")]
            args["look_at_position"] = [float(x) for x in sys.argv[4].split(",")]
        r = send({"name": "screen_capture", "arguments": args, "save": sys.argv[2]})
    else:
        sys.exit(__doc__)
    print(f"[{r.get('ms', '?')} ms]", text(r)[:6000])
