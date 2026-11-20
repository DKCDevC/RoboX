#!/usr/bin/env python
"""Checks before a render, so a broken setup stops at once instead of producing hundreds of bad frames.

  python preflight.py --ep <episode> [--shot s01] [--accept-size]      (render.py runs it by itself; --no-preflight skips)

Checks, in order (each failure stops with what to do):
  1. the Studio in studio_txt is connected                (bridge running, MCP on)
  2. it is in Edit mode, not Play                         (Play: the scene code cannot run; E01 lost 367 frames to it)
  3. only one Studio is open                              (a second window dropped the MCP link on E01; warning only)
  3b. the place window is not minimised, is maximised and in front (Windows check; --fix restores it, render.py does that
      by default and stops only when it cannot)
  4. the kit and the episode are loaded                   (shared.MT, the first shot in MT.SHOTS)
  5. a real capture of the first shot is not blank        (hidden, covered or minimised window = white picture)
  6. the capture size matches the episode's first render  (<episode>/capture_size.json; a smaller window = softer frames)
"""
import json, os, sys
import episode, rb

MIN_W, MIN_H = 1280, 700


def fail(msg):
    print("PREFLIGHT FAILED:", msg)
    sys.exit(2)


def place_window(fix=False):
    """Windows-level check of the Studio window that has a place open (title "<place> - Roblox Studio").
    Returns a note, or stops. fix=True restores, maximises and raises it instead of stopping."""
    if os.name != "nt":
        return "window check skipped (not Windows)"
    import ctypes
    from ctypes import wintypes
    u = ctypes.windll.user32
    found = []

    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cb(h, _):
        n = u.GetWindowTextLengthW(h)
        if n and u.IsWindowVisible(h):
            buf = ctypes.create_unicode_buffer(n + 1); u.GetWindowTextW(h, buf, n + 1)
            t = buf.value
            if t.endswith(" - Roblox Studio"):
                found.append((h, t))
        return True
    u.EnumWindows(cb, 0)
    if not found:
        return "window check skipped (Studio window in another session or non-standard title)"
    if len(found) > 1:
        print("preflight WARNING: several place windows:", ", ".join(t for _, t in found), "- the first one is checked")
    h, title = found[0]
    problems = []
    if u.IsIconic(h): problems.append("minimised")
    if not u.IsZoomed(h): problems.append("not maximised")
    if u.GetForegroundWindow() != h: problems.append("not the front window (other windows may cover it)")
    if not problems:
        return f"window \"{title}\" maximised and in front"
    if not fix:
        fail(f"the Studio window \"{title}\" is {', '.join(problems)}. Studio stops drawing the 3D view when it is hidden. "
             "Maximise it and bring it to the front, or run again with --fix to do that automatically.")
    u.ShowWindow(h, 3)                      # SW_MAXIMIZE (also restores a minimised window)
    u.keybd_event(0x12, 0, 0, 0); u.keybd_event(0x12, 0, 2, 0)   # tap Alt: Windows only lets a foreground change through after input
    u.SetForegroundWindow(h)
    import time; time.sleep(0.8)
    left = [p for p, ok in (("minimised", not u.IsIconic(h)), ("not maximised", u.IsZoomed(h)), ("not in front", u.GetForegroundWindow() == h)) if not ok]
    if left:
        fail(f"could not fix the Studio window ({', '.join(left)}). Bring \"{title}\" to the front by hand.")
    return f"window \"{title}\" fixed: was {', '.join(problems)}"


def run(ep, shot=None, accept_size=False, fix=False):
    queued = [f for f in os.listdir(os.path.join(rb.HERE, "queue")) if f.endswith(".json")] if os.path.isdir(os.path.join(rb.HERE, "queue")) else []
    if queued:
        print(f"preflight: the bridge still has {len(queued)} job(s) queued; live checks skipped (the bridge guards a running render)")
        return
    sid = open(rb.SID_F, encoding="utf-8-sig").read().strip() if os.path.exists(rb.SID_F) else ""
    ss = rb.studios()
    if not ss:
        fail("no Studio answered. Is start_bridge.bat running, Studio open with the place, and 'Enable Studio as MCP server' on?")
    me = next((s for s in ss if s["id"] == sid), None) or (ss[0] if len(ss) == 1 else None)
    if not me:
        fail(f"{len(ss)} Studios are open and none matches studio_id.txt. Run: python rb.py studios")
    if me["id"] != sid:
        open(rb.SID_F, "w").write(me["id"]); sid = me["id"]
    rb.sid = sid
    state = me.get("state") or ""
    if "Current Studio Mode: Edit" not in state:
        fail("Studio is not in Edit mode (Play/Run is on). Stop it: python rb.py call start_stop_play \"{\\\"is_start\\\": false}\"")
    win_note = place_window(fix)
    others = [s for s in ss if s["id"] != sid]
    if others:
        print(f"preflight WARNING: {len(others)} other Studio window(s) open ({', '.join(str(s.get('name')) for s in others)}). "
              "Close them: a second window dropped the MCP link during the E01 render.")
    shot = shot or episode.shots(ep)[0][0]
    code = f'''if not shared.MT or not shared.MT.SHOTS or not shared.MT.SHOTS["{shot}"] then return "NOT_LOADED" end
local ok, e = pcall(function() shared.MT.cur = nil; shared.MT.frame("{shot}", 1) end)
task.wait(1.0)
return ok and "OK" or ("ERR " .. tostring(e))'''
    r = rb.text(rb.lua(code)).strip()
    if "NOT_LOADED" in r:
        fail(f"the kit or the episode is not loaded in Studio (no MT.SHOTS[\"{shot}\"]). Run: python load.py --ep \"{ep}\"")
    if not r.startswith("OK"):
        fail(f"shot {shot} frame 1 failed in Studio: {r[:300]}")
    cap = os.path.join(rb.HERE, "caps", "preflight.png")
    os.makedirs(os.path.dirname(cap), exist_ok=True)
    rb.send({"name": "screen_capture", "arguments": {"capture_id": "ScreenCapture_1", "studio_id": sid}, "save": cap})
    import cv2
    im = cv2.imread(cap)
    if im is None:
        fail("the test capture did not arrive (look at bridge.log)")
    h, w = im.shape[:2]
    if float(im.std()) < 6:
        fail("the test capture is blank. Bring the Studio window to the front, maximise it, keep it uncovered, then run again.")
    size_f = episode.path(ep, "capture_size.json")
    if os.path.exists(size_f) and not accept_size:
        want = json.load(open(size_f))
        if (want["w"], want["h"]) != (w, h):
            fail(f"captures are {w}x{h} now, {want['w']}x{want['h']} on this episode's earlier renders. Maximise Studio and restore "
                 "the same panel layout, or pass --accept-size if the new size is wanted (then re-render whole shots, not single frames).")
    else:
        if w < MIN_W or h < MIN_H:
            fail(f"captures are only {w}x{h} (want at least {MIN_W}x{MIN_H}): maximise the Studio window.")
        json.dump({"w": w, "h": h}, open(size_f, "w"))
    print(f"preflight ok: Studio {state.split(chr(10))[0].replace('- ', '')}; {win_note}; test capture {w}x{h}, not blank")


if __name__ == "__main__":
    argv = sys.argv[1:]
    if "--window-only" in argv:            # just the Windows check (no bridge, no episode needed)
        argv.remove("--window-only")
        print(place_window("--fix" in argv)); sys.exit()
    ep = episode.ep_dir(argv)
    shot = episode.pop_flag(argv, "--shot")
    accept = bool(episode.pop_flag(argv, "--accept-size", False, has_value=False))
    run(ep, shot, accept, bool(episode.pop_flag(argv, "--fix", False, has_value=False)))
