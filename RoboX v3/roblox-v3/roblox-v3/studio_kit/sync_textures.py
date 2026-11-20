#!/usr/bin/env python
"""Sync local PNG faces & clothes into the latest Roblox Studio version folder after a Studio auto-update.

  python sync_textures.py [--src <my_assets folder>] [--name <subfolder>]

Copies PNGs from <src>/faces/out* -> %LOCALAPPDATA%\\Roblox\\Versions\\<latest>\\content\\textures\\<name>_faces\\
and <src>/cloth -> ...\\content\\textures\\<name>_cloth\\ (or copies every subfolder directly into content/textures/).
Safe to run repeatedly (skips files with identical size and mtime)."""
import os, shutil, sys


def latest_studio_dir():
    local_app = os.environ.get("LOCALAPPDATA") or os.path.join(os.environ.get("USERPROFILE", ""), "AppData", "Local")
    search_roots = [
        os.path.join(local_app, "Roblox", "Versions"),
        r"C:\Program Files\Roblox\Versions",
        r"C:\Program Files (x86)\Roblox\Versions",
    ]
    found = []
    for versions in search_roots:
        if not os.path.isdir(versions):
            continue
        for entry in os.listdir(versions):
            d = os.path.join(versions, entry)
            exe = os.path.join(d, "RobloxStudioBeta.exe")
            if os.path.isfile(exe):
                found.append((os.path.getmtime(exe), d))
    if not found:
        return None
    found.sort(reverse=True)
    return found[0][1]


def sync_folder(src_dir, dst_dir):
    os.makedirs(dst_dir, exist_ok=True)
    copied = 0
    for fn in os.listdir(src_dir):
        if not fn.lower().endswith((".png", ".jpg", ".jpeg")):
            continue
        sp = os.path.join(src_dir, fn)
        dp = os.path.join(dst_dir, fn)
        if not os.path.isfile(sp):
            continue
        if os.path.exists(dp) and os.path.getsize(sp) == os.path.getsize(dp) and abs(os.path.getmtime(sp) - os.path.getmtime(dp)) < 1:
            continue
        shutil.copy2(sp, dp)
        copied += 1
    return copied


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    default_assets = os.path.abspath(os.path.join(here, "..", "..", "..", "..", "my_assets"))
    argv = sys.argv[1:]
    src = default_assets
    prefix = "robox"
    i = 0
    while i < len(argv):
        if argv[i] == "--src" and i + 1 < len(argv):
            src = argv[i + 1]; i += 2
        elif argv[i] == "--name" and i + 1 < len(argv):
            prefix = argv[i + 1]; i += 2
        else:
            i += 1

    studio_dir = latest_studio_dir()
    if not studio_dir:
        sys.exit("RobloxStudioBeta.exe not found under %LOCALAPPDATA%\\Roblox\\Versions")
    tex_root = os.path.join(studio_dir, "content", "textures")
    if not os.path.isdir(src):
        sys.exit(f"assets folder not found: {src}")

    total = 0
    for sub, target in [
        (os.path.join(src, "cloth"), os.path.join(tex_root, prefix)),
        (os.path.join(src, "faces", "out"), os.path.join(tex_root, prefix)),
    ]:
        if os.path.isdir(sub):
            n = sync_folder(sub, target)
            total += n
            print(f"synced {n:3d} file(s): {sub} -> {target}")
    print(f"done ({total} updated) in {studio_dir}")


if __name__ == "__main__":
    main()
