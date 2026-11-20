#!/usr/bin/env python
"""1-click end-to-end episode builder (designed for unattended / overnight runs).

  python build_episode.py --ep <episode> [--tiles 2|4] [--step 1|2] [--jobs 2]
                          [--resume] [--old-caps] [--skip-gates] [--skip-sync] [--skip-load] [--skip-render] [--redo-caps] [--clean]

Runs the full RoboX v3 pipeline in order:
  1. sync_textures.py   (updates Studio local textures if Roblox auto-updated)
  2. load.py            (loads kit + lib12 acting + episode Lua + words.json lip-sync)
  3. fov.py (+ tiles4k.py if --tiles 4)
  4. render.py          (queues shots and waits until bridge.mjs completes all jobs)
  5. stitch.py          (joins tiles into 1080x1920 or 4K frames, filling stepped frames if --step 2)
  6. tools/make_caps.py (generates caps.ass from words.json if present: the v3.1 one-word look; --old-caps = the E01-E03 look)
  7. join.py            (muxes picture + caps + voice + ducked music + SFX -> out/final.mp4)
  8. --clean (optional) (removes intermediate frames/ and picture*.mp4 once out/final.mp4 is verified)

Requirement: start_bridge.bat and Roblox Studio (Edit mode) must already be running."""
import os, shutil, subprocess, sys, time
import episode, rb, stage

KIT = episode.KIT
TOOLS = os.path.abspath(os.path.join(KIT, "..", "tools"))
PY = sys.executable


def run_step(label, args, fatal=True):
    print(f"\n=== [{label}] {' '.join(args)} ===")
    r = subprocess.run([PY] + args, cwd=KIT)
    if r.returncode != 0:
        if fatal:
            sys.exit(f"FAILED at step [{label}] (exit code {r.returncode})")
        print(f"warning: step [{label}] exited with code {r.returncode} (continuing)")
    return r.returncode == 0


def keep_screen_on():
    """Ask Windows to keep the display on (and so not lock) while this process runs, the way video players do.
    E03, 2026-11-20: the PC locked itself 50 min into the render, every capture timed out and the bridge stopped."""
    if os.name == "nt":
        import ctypes
        ctypes.windll.kernel32.SetThreadExecutionState(0x80000000 | 0x00000001 | 0x00000002)  # CONTINUOUS|SYSTEM|DISPLAY


def wait_for_render():
    keep_screen_on()
    qdir = os.path.join(KIT, "queue")
    prog = os.path.join(KIT, "render_progress.txt")
    stopped = os.path.join(KIT, "render_stopped.txt")
    last_line = ""
    print("\n=== [wait] waiting for bridge.mjs to finish all queued render jobs ===")
    # Give bridge a moment to pick up the first job
    time.sleep(2.0)
    while True:
        if os.path.exists(stopped):
            msg = open(stopped, encoding="utf-8", errors="replace").read().strip()
            sys.exit(f"\nRENDER INTERRUPTED: {msg}\nFix Studio and re-run with: python build_episode.py --ep <ep> --resume")
        queued = [f for f in os.listdir(qdir) if f.endswith(".json")] if os.path.isdir(qdir) else []
        cur = open(prog, encoding="utf-8", errors="replace").read().strip() if os.path.exists(prog) else ""
        if cur and cur != last_line:
            print(f"  progress: {cur}  (queued: {len(queued)})", flush=True)
            last_line = cur
        # Done when queue is empty AND bridge_alive.txt has been touched recently (bridge idle)
        alive = os.path.join(KIT, "bridge_alive.txt")
        if not queued and os.path.exists(alive):
            try:
                age = time.time() - os.path.getmtime(alive)
                if age < 3.0:
                    print("  all render jobs complete!")
                    return
            except OSError:
                pass
        time.sleep(5.0)


def dir_size_bytes(path):
    total = 0
    for root, _, files in os.walk(path):
        for fn in files:
            try:
                total += os.path.getsize(os.path.join(root, fn))
            except OSError:
                pass
    return total


def clean_episode(ep):
    final_mp4 = episode.path(ep, "out", "final.mp4")
    if not (os.path.isfile(final_mp4) and os.path.getsize(final_mp4) > 0):
        print("skip --clean: out/final.mp4 not found or empty (keeping frames/ safe)")
        return
    freed = 0
    frames_dir = episode.path(ep, "frames")
    if os.path.isdir(frames_dir):
        freed += dir_size_bytes(frames_dir)
        shutil.rmtree(frames_dir, ignore_errors=True)
    for name in ("picture.mp4", "picture_hd.mp4"):
        p = episode.path(ep, "out", name)
        if os.path.isfile(p):
            try:
                freed += os.path.getsize(p)
                os.remove(p)
            except OSError:
                pass
    seq_dir = episode.path(ep, "out", "seq")
    if os.path.isdir(seq_dir):
        freed += dir_size_bytes(seq_dir)
        shutil.rmtree(seq_dir, ignore_errors=True)
    print(f"cleaned intermediate files: freed {freed / (1024 * 1024):.1f} MB (kept out/final.mp4)")


def main():
    argv = sys.argv[1:]
    ep = episode.ep_dir(argv)
    tiles = int(episode.pop_flag(argv, "--tiles", "2"))
    step = int(episode.pop_flag(argv, "--step", "1"))
    jobs = int(episode.pop_flag(argv, "--jobs", "2"))
    resume = bool(episode.pop_flag(argv, "--resume", False, has_value=False))
    old_caps = bool(episode.pop_flag(argv, "--old-caps", False, has_value=False))
    skip_gates = bool(episode.pop_flag(argv, "--skip-gates", False, has_value=False))
    skip_sync = bool(episode.pop_flag(argv, "--skip-sync", False, has_value=False))
    skip_load = bool(episode.pop_flag(argv, "--skip-load", False, has_value=False))
    skip_render = bool(episode.pop_flag(argv, "--skip-render", False, has_value=False))
    redo_caps = bool(episode.pop_flag(argv, "--redo-caps", False, has_value=False))
    clean = bool(episode.pop_flag(argv, "--clean", False, has_value=False))

    t0 = time.time()
    if not skip_render and not resume:
        ok, msg = stage.gate(ep)       # cast, set and storyboard approved by the user (stage.py)
        print("stages:", msg)
        if not ok and not skip_gates:
            sys.exit("STOPPED before the render: the build is gated on the user's approvals. Run: python stage.py --ep <episode> status")
    print(f"build_episode: ep={ep} tiles={tiles} step={step} jobs={jobs} resume={resume}")

    if not skip_sync and not skip_render:
        run_step("1/7 sync_textures", ["sync_textures.py"], fatal=False)

    if not skip_load and not skip_render and not resume:
        run_step("2/7 load", ["load.py", "--ep", ep])

    if not skip_render and not resume:
        if not os.path.exists(episode.path(ep, "fov.json")):
            run_step("3/7 fov", ["fov.py", "--ep", ep])
        if tiles == 4 and not os.path.exists(episode.path(ep, "tiles4k.json")):
            run_step("3b/7 tiles4k", ["tiles4k.py", "--ep", ep])
            run_step("3c/7 reload_tiles4k", ["load.py", "--ep", ep])

    if not skip_render:
        if resume:
            run_step("4/7 render --resume", ["render.py", "--resume", "--ep", ep])
        else:
            run_step("4/7 render", ["render.py", "--ep", ep, "--tiles", str(tiles), "--step", str(step)])
        wait_for_render()

    if tiles in (2, 4):
        run_step("5/7 stitch", ["stitch.py", "--ep", ep, "--tiles", str(tiles), "--step", str(step), "--jobs", str(jobs)])

    caps_path = episode.path(ep, "caps.ass")
    words_path = episode.path(ep, "words.json")
    sheet_path = episode.path(ep, "script-sheet.md")
    if os.path.exists(words_path) and (redo_caps or not os.path.exists(caps_path)):
        # v3.1 look (captions.md): one word per caption, normal case, no key word = make_caps defaults.
        # --old-caps: the E01-E03 look (1-2 words, lowercase, red key words from the sheet).
        cap_args = [os.path.join(TOOLS, "make_caps.py"), words_path, caps_path]
        if old_caps:
            cap_args += ["--pair", "--lowercase", "--y", "1402", "--fs", "68", "--outline", "3"]
            if os.path.exists(sheet_path):
                cap_args += ["--sheet", sheet_path]
        run_step("6/7 make_caps", cap_args)

    src_mode = "4k" if tiles == 4 else ("hd" if tiles == 2 else "raw1")
    join_args = ["join.py", "--ep", ep, "--src", src_mode]
    if os.path.exists(caps_path):
        join_args += ["--caps", caps_path]
    run_step("7/7 join", join_args)

    if clean:
        print("\n=== [8/8 clean] removing intermediate frames ===")
        clean_episode(ep)

    elapsed = (time.time() - t0) / 60.0
    print(f"\nDONE in {elapsed:.1f} min -> {episode.path(ep, 'out', 'final.mp4')}")


if __name__ == "__main__":
    main()
