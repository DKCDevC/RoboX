#!/usr/bin/env python
"""Join an episode's stitched frames into the picture track, then (optionally) captions + voice + music.

  python join.py --ep <episode> [--src hd|4k|raw1] [--caps caps.ass] [--music audio/music.mp3] [--music-db -16]

--src hd (default) frames/hd/<id>/ 1080x1920 · 4k frames/4k/<id>/ 2160x3840 (also writes a 1080x1920 copy) ·
      raw1 frames/raw1/<id>/ landscape preview captures, centre-cropped to 9:16 (blurry: previews only).
Each shot gets exactly its frame count from shots.json; missing frames repeat the last good one (listed as short shots).
Writes out/picture.mp4 (30 fps, no sound). With audio/vo.wav present it also writes out/final.mp4: captions burned in
(--caps, an ASS file from tools/make_caps.py; fonts from <episode>/fonts/), voice + music under it, -14 LUFS, -1 dBTP."""
import os, shutil, subprocess, sys
import episode

argv = sys.argv[1:]
ep = episode.ep_dir(argv)
src = episode.pop_flag(argv, "--src", "hd")
caps = episode.pop_flag(argv, "--caps")
music = episode.pop_flag(argv, "--music") or (episode.path(ep, "audio", "music.mp3") if os.path.exists(episode.path(ep, "audio", "music.mp3")) else None)
music_db = float(episode.pop_flag(argv, "--music-db", "-16"))
folder = {"hd": "hd", "4k": "4k", "raw1": "raw1"}.get(src) or sys.exit("--src is hd, 4k or raw1")
outdir = episode.path(ep, "out", make=True)


def run(cmd):
    subprocess.run(["ffmpeg", "-y", "-v", "error"] + cmd, check=True)


# 1. frame list, one entry per output frame
lst, short = [], []
for sid, n in episode.shots(ep):
    d = episode.path(ep, "frames", folder, sid)
    fr = sorted(f for f in os.listdir(d) if f[:5].isdigit() and not f.endswith(".tmp.jpg"))[:n] if os.path.isdir(d) else []
    if len(fr) < n:
        short.append(f"{sid}:{len(fr)}/{n}")
    for j in range(n):
        if fr:
            lst.append(os.path.join(d, fr[min(j, len(fr) - 1)]))
        elif lst:
            lst.append(lst[-1])
if not lst:
    sys.exit(f"no frames in {episode.path(ep, 'frames', folder)} (render.py, then stitch.py)")
print("frames", len(lst), f"({len(lst) / episode.FPS:.1f} s)", "short shots:", " ".join(short) or "none")
# Number the frames 00001.jpg ... in one folder (hard links, no copies) and read them at exactly 30 fps. A concat list
# with "duration 0.033333" per image rounded its timestamps: frame 3 came out twice and every later frame one frame late
# (E01, 2026-11-19: each cut and each mouth landed a frame after the voice).
seq = episode.path(ep, "out", "seq")
shutil.rmtree(seq, ignore_errors=True); os.makedirs(seq)
for k, p in enumerate(lst, 1):
    dst = os.path.join(seq, f"{k:05d}{os.path.splitext(p)[1]}")
    try: os.link(p, dst)
    except OSError: shutil.copy(p, dst)
ext = os.path.splitext(lst[0])[1]

# 2. picture track
pic = os.path.join(outdir, "picture.mp4")
vf = {"hd": "scale=1080:1920:flags=lanczos,setsar=1", "4k": "setsar=1",
      "raw1": "crop=trunc(ih*9/16/2)*2:ih,scale=1080:1920:flags=lanczos,setsar=1"}[src]
run(["-framerate", str(episode.FPS), "-i", os.path.join(seq, "%05d" + ext), "-frames:v", str(len(lst)), "-vf", vf,
     "-c:v", "libx264", "-crf", "16", "-preset", "veryfast", "-pix_fmt", "yuv420p", "-g", "15", "-movflags", "+faststart", pic + ".part.mp4"])
os.replace(pic + ".part.mp4", pic)
shutil.rmtree(seq, ignore_errors=True)
print("picture ->", pic)
if src == "4k":
    hd = os.path.join(outdir, "picture_hd.mp4")
    run(["-i", pic, "-vf", "scale=1080:1920:flags=lanczos", "-c:v", "libx264", "-crf", "17", "-preset", "veryfast",
         "-pix_fmt", "yuv420p", "-g", "15", "-movflags", "+faststart", hd])
    print("hd copy ->", hd)
    pic_for_final = hd
else:
    pic_for_final = pic

# 3. final: captions + voice (+ music), loudness to -14 LUFS / -1 dBTP
vo = episode.path(ep, "audio", "vo.wav")
if not os.path.exists(vo):
    print("no audio/vo.wav: stopping at the picture track")
    sys.exit()
vfx = []
if caps:
    capsp = os.path.abspath(caps).replace("\\", "/").replace(":", "\\:")
    fonts = episode.path(ep, "fonts").replace("\\", "/").replace(":", "\\:")
    vfx = ["-vf", f"ass='{capsp}'" + (f":fontsdir='{fonts}'" if os.path.isdir(episode.path(ep, "fonts")) else "")]
ins = ["-i", pic_for_final, "-i", vo]
if music:
    ins += ["-stream_loop", "-1", "-i", music]
    af = f"[2:a]volume={music_db}dB[m];[1:a]apad[v];[v][m]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-14:TP=-1.5:LRA=11[a]"   # apad: the voice ends before the picture; keep the tail
else:
    af = "[1:a]apad,loudnorm=I=-14:TP=-1.5:LRA=11[a]"
final = os.path.join(outdir, "final.mp4")
run(ins + vfx + ["-filter_complex", af, "-map", "0:v", "-map", "[a]",
                 "-c:v", "libx264", "-profile:v", "high", "-pix_fmt", "yuv420p", "-r", str(episode.FPS), "-b:v", "12M", "-maxrate", "16M",
                 "-bufsize", "24M", "-g", "15", "-color_primaries", "bt709", "-color_trc", "bt709", "-colorspace", "bt709",
                 "-c:a", "aac", "-b:a", "320k", "-ar", "48000", "-shortest", "-movflags", "+faststart", final])
print("final ->", final)
