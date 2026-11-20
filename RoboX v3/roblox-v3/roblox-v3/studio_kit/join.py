#!/usr/bin/env python
"""Join an episode's stitched frames into the picture track, then (optionally) captions + voice + music + SFX.

  python join.py --ep <episode> [--src hd|4k|raw1] [--caps caps.ass] [--music audio/music.mp3] [--music-db -16]
                                [--cues audio/cues.json] [--no-duck]

--src hd (default) frames/hd/<id>/ 1080x1920 · 4k frames/4k/<id>/ 2160x3840 (also writes a 1080x1920 copy) ·
      raw1 frames/raw1/<id>/ landscape preview captures, centre-cropped to 9:16 (blurry: previews only).
--cues PATH        optional JSON cue sheet (auto-detected at <episode>/audio/cues.json if present) supporting:
                     "music": [{"file": "...", "start": 0.0, "end": 42.0, "db": -16, "fade": 0.8}, ...]
                     "duck":  [{"start": 41.2, "end": 42.4, "db": -14}, ...]
                     "sfx":   [{"file": "...", "t": 1.0, "db": -6}, ...]
--no-duck          disable automatic voice-triggered sidechain ducking on the music bus.
--blur W           light motion blur: each frame = (1-2W) itself + W each neighbour in the same shot (default 0.2; 0 = off)
Each shot gets exactly its frame count from shots.json; missing frames repeat the last good one (listed as short shots).
Writes out/picture.mp4 (30 fps, no sound). With audio/vo.wav present it also writes out/final.mp4: captions burned in
(--caps, an ASS file from tools/make_caps.py; fonts from <episode>/fonts/), voice + ducked music + SFX, -14 LUFS, -1.5 dBTP."""
import json, os, shutil, subprocess, sys
import episode

argv = sys.argv[1:]
ep = episode.ep_dir(argv)
src = episode.pop_flag(argv, "--src", "hd")
caps = episode.pop_flag(argv, "--caps")
music = episode.pop_flag(argv, "--music") or (episode.path(ep, "audio", "music.mp3") if os.path.exists(episode.path(ep, "audio", "music.mp3")) else None)
music_db = float(episode.pop_flag(argv, "--music-db", "-16"))
cues_arg = episode.pop_flag(argv, "--cues")
cues_path = cues_arg or (episode.path(ep, "audio", "cues.json") if os.path.exists(episode.path(ep, "audio", "cues.json")) else None)
auto_duck = not bool(episode.pop_flag(argv, "--no-duck", False, has_value=False))
# Reference grade (look-reference.md: slight vignette, corner/centre about 0.89; punchier contrast). vignette angle 0.24
# measured on flat grey = 0.891. Applied to the picture before captions, so the captions stay white. --no-grade turns it off.
GRADE = "" if episode.pop_flag(argv, "--no-grade", False, has_value=False) else ",eq=contrast=1.06:saturation=1.06,vignette=angle=0.24"
BLUR = float(episode.pop_flag(argv, "--blur", "0.2"))
if not 0 <= BLUR <= 0.33:
    sys.exit("--blur is 0 (off) to 0.33 (an even 3-frame blend); default 0.2")
folder = {"hd": "hd", "4k": "4k", "raw1": "raw1"}.get(src) or sys.exit("--src is hd, 4k or raw1")
outdir = episode.path(ep, "out", make=True)


def run(cmd):
    subprocess.run(["ffmpeg", "-y", "-v", "error"] + cmd, check=True)


def resolve_audio(ep_path, rel):
    if os.path.isabs(rel) and os.path.exists(rel):
        return rel
    for base in (ep_path, os.path.join(ep_path, "audio"), os.path.abspath(os.path.join(episode.KIT, "..", "assets"))):
        cand = os.path.join(base, rel)
        if os.path.exists(cand):
            return cand
    return None


def blend_one(a):
    """Write frame k as a light 3-frame blend (prev, cur, next of the same shot), the cheap stand-in for motion blur."""
    prev, cur, nxt, dst, w = a
    import cv2
    c = cv2.imread(cur).astype("float32")
    acc, tot = c * (1 - 2 * w), 1 - 2 * w
    for p in (prev, nxt):
        im = cv2.imread(p).astype("float32") if p and p != cur else c
        acc += im * w; tot += w
    cv2.imwrite(dst, (acc / tot).clip(0, 255).astype("uint8"), [cv2.IMWRITE_JPEG_QUALITY, 95])

# 1. frame list, one entry per output frame
lst, short, shot_of = [], [], []
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
        else:
            continue
        shot_of.append(sid)
if not lst:
    sys.exit(f"no frames in {episode.path(ep, 'frames', folder)} (render.py, then stitch.py)")
total_dur = len(lst) / episode.FPS
print("frames", len(lst), f"({total_dur:.1f} s)", "short shots:", " ".join(short) or "none")
# Number the frames 00001.jpg ... in one folder (hard links, no copies) and read them at exactly 30 fps. A concat list
# with "duration 0.033333" per image rounded its timestamps: frame 3 came out twice and every later frame one frame late
# (E01, 2026-11-19: each cut and each mouth landed a frame after the voice).
seq = episode.path(ep, "out", "seq")
shutil.rmtree(seq, ignore_errors=True); os.makedirs(seq)
ext = os.path.splitext(lst[0])[1]
if BLUR > 0:
    # Light motion blur: each frame is blended with its neighbours inside the same shot (never across a cut). Studio frames
    # are sharp stills, and at 30 fps busy textures and walks looked jerky without it (E03, 0:10-0:11).
    from multiprocessing.pool import ThreadPool
    ext = ".jpg"
    jobs = []
    for k, p in enumerate(lst):
        prev = lst[k - 1] if k > 0 and shot_of[k - 1] == shot_of[k] else None
        nxt = lst[k + 1] if k + 1 < len(lst) and shot_of[k + 1] == shot_of[k] else None
        jobs.append((prev, p, nxt, os.path.join(seq, f"{k + 1:05d}.jpg"), BLUR))
    with ThreadPool(os.cpu_count() or 4) as tp:
        tp.map(blend_one, jobs, chunksize=8)
    print(f"motion blur: {BLUR:.2f} of each neighbour frame blended in (--blur 0 turns it off)")
else:
    for k, p in enumerate(lst, 1):
        dst = os.path.join(seq, f"{k:05d}{os.path.splitext(p)[1]}")
        try: os.link(p, dst)
        except OSError: shutil.copy(p, dst)

# 2. picture track
pic = os.path.join(outdir, "picture.mp4")
vf = {"hd": "scale=1080:1920:flags=lanczos,setsar=1", "4k": "setsar=1",
      "raw1": "crop=trunc(ih*9/16/2)*2:ih,scale=1080:1920:flags=lanczos,setsar=1"}[src] + GRADE
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

# 3. final: captions + voice + ducked music + SFX, loudness to -14 LUFS / -1.5 dBTP
vo = episode.path(ep, "audio", "vo.wav")
if not os.path.exists(vo):
    print("no audio/vo.wav: stopping at the picture track")
    sys.exit()
vfx = []
if caps:
    capsp = os.path.abspath(caps).replace("\\", "/").replace(":", "\\:")
    ep_fonts = episode.path(ep, "fonts")
    kit_fonts = os.path.abspath(os.path.join(episode.KIT, "..", "assets", "fonts"))
    font_dir = ep_fonts if os.path.isdir(ep_fonts) else (kit_fonts if os.path.isdir(kit_fonts) else None)
    fonts_arg = f":fontsdir='{font_dir.replace(chr(92), '/').replace(':', chr(92) + ':')}'" if font_dir else ""
    vfx = ["-vf", f"ass='{capsp}'{fonts_arg}"]

cues = {}
if cues_path and os.path.exists(cues_path):
    cues = json.load(open(cues_path, encoding="utf-8-sig"))
    print("audio cues:", cues_path)

STD_FMT = "aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo"
ins = ["-i", pic_for_final, "-i", vo]
filters = []

# Voice stem: pad to picture length; split if sidechain ducking is needed
music_cues = cues.get("music") or ([] if not music else [{"file": music, "start": 0.0, "end": total_dur, "db": music_db, "fade": 0.5}])
duck_cues = cues.get("duck") or []
sfx_cues = cues.get("sfx") or []

# Resolve valid music & sfx inputs
valid_music = []
for mc in music_cues:
    fp = resolve_audio(ep, mc["file"])
    if fp:
        valid_music.append((fp, mc))
    else:
        print("warning: missing music cue file:", mc["file"])

valid_sfx = []
for sc in sfx_cues:
    fp = resolve_audio(ep, sc["file"])
    if fp:
        valid_sfx.append((fp, sc))
    else:
        print("warning: missing sfx cue file:", sc["file"])

use_sidechain = auto_duck and len(valid_music) > 0
if use_sidechain:
    filters.append(f"[1:a]{STD_FMT},apad=whole_dur={total_dur:.3f},asplit=2[vo_mix][vo_sc]")
else:
    filters.append(f"[1:a]{STD_FMT},apad=whole_dur={total_dur:.3f}[vo_mix]")

mix_labels = ["[vo_mix]"]
next_idx = 2

# Music bus (single or multi-segment mood switching + fade + explicit duck windows + auto sidechain ducking)
if valid_music:
    m_labels = []
    for k, (fp, mc) in enumerate(valid_music):
        ins += ["-stream_loop", "-1", "-i", fp]
        idx = next_idx; next_idx += 1
        st = max(0.0, float(mc.get("start", 0.0)))
        en = float(mc.get("end", total_dur))
        dur = max(0.1, en - st)
        db = float(mc.get("db", music_db))
        fade = max(0.0, min(float(mc.get("fade", 0.5)), dur / 2.5))
        ms = int(round(st * 1000))
        chain = [f"[{idx}:a]{STD_FMT}", f"atrim=0:{dur:.3f}", "asetpts=PTS-STARTPTS", f"volume={db}dB"]
        if fade > 0.01:
            chain.append(f"afade=t=in:st=0:d={fade:.3f}")
            chain.append(f"afade=t=out:st={max(0.0, dur - fade):.3f}:d={fade:.3f}")
        if ms > 0:
            chain.append(f"adelay={ms}|{ms}")
        lbl = f"[m{k}]"
        filters.append(",".join(chain) + lbl)
        m_labels.append(lbl)

    if len(m_labels) == 1:
        filters.append(f"{m_labels[0]}anull[mbus0]")
    else:
        filters.append(f"{''.join(m_labels)}amix=inputs={len(m_labels)}:duration=longest:normalize=0[mbus0]")

    # Apply explicit duck windows from cues.json (e.g. -14dB under twist/quiet beats)
    cur_m = "[mbus0]"
    for d_idx, dc in enumerate(duck_cues):
        ds = float(dc.get("start", 0.0))
        de = float(dc.get("end", ds + 0.5))
        ddb = float(dc.get("db", -12.0))
        nxt = f"[mduck{d_idx}]"
        filters.append(f"{cur_m}volume=volume={ddb}dB:enable='between(t,{ds:.3f},{de:.3f})':eval=frame{nxt}")
        cur_m = nxt

    if use_sidechain:
        filters.append(f"{cur_m}[vo_sc]sidechaincompress=threshold=0.02:ratio=4:attack=20:release=250:makeup=1[mbus_final]")
        mix_labels.append("[mbus_final]")
    else:
        mix_labels.append(cur_m)

# SFX stems (timestamped whooshes, impacts, rises)
for k, (fp, sc) in enumerate(valid_sfx):
    ins += ["-i", fp]
    idx = next_idx; next_idx += 1
    t_sec = max(0.0, float(sc.get("t", 0.0)))
    db = float(sc.get("db", -6.0))
    ms = int(round(t_sec * 1000))
    chain = [f"[{idx}:a]{STD_FMT}", f"volume={db}dB"]
    if ms > 0:
        chain.append(f"adelay={ms}|{ms}")
    lbl = f"[sfx{k}]"
    filters.append(",".join(chain) + lbl)
    mix_labels.append(lbl)

if len(mix_labels) == 1:
    filters.append(f"{mix_labels[0]}loudnorm=I=-14:TP=-1.5:LRA=11[a]")
else:
    filters.append(f"{''.join(mix_labels)}amix=inputs={len(mix_labels)}:duration=first:normalize=0,loudnorm=I=-14:TP=-1.5:LRA=11[a]")

af = ";".join(filters)
final = os.path.join(outdir, "final.mp4")
run(ins + vfx + ["-filter_complex", af, "-map", "0:v", "-map", "[a]",
                 "-c:v", "libx264", "-profile:v", "high", "-pix_fmt", "yuv420p", "-r", str(episode.FPS), "-b:v", "12M", "-maxrate", "16M",
                 "-bufsize", "24M", "-g", "15", "-color_primaries", "bt709", "-color_trc", "bt709", "-colorspace", "bt709",
                 "-c:a", "aac", "-b:a", "320k", "-ar", "48000", "-shortest", "-movflags", "+faststart", final])
print(f"final -> {final} (music={len(valid_music)}, sfx={len(valid_sfx)}, duck={'auto' if use_sidechain else 'off'}+{len(duck_cues)} cues)")
