# pipeline.md: one Roblox story reel, start to finish (Windows + Roblox Studio)

One route only: **Claude builds and renders in Roblox Studio through its MCP, on the same Windows PC** (`studio.md`). The old Mac route (Studio shot runner played live + OBS recording + Moon Animator) and the Blender route are in `legacy/` and are not used unless the user asks.

Who: the user, solo, Windows PC, Claude Code (desktop app Code tab or PowerShell), a small monthly tool budget (ElevenLabs takes most of it), prefers free assets over building.
Output: vertical 1080×1920, 30 fps, 60 s–3 min, "In this town…" story in the reference look (`look-reference.md`).
Tags: **REF-RANGE** = measured on the refs; **HYPOTHESIS** = not proven; **ESTIMATE** = time guess, replace with real numbers after the first test; **UNVERIFIED** = nobody has checked it on this PC yet.

**Money rules (HARD):** never spend money or paid credits without asking the user first (ElevenLabs generations, paid plugins, CapCut Pro, any asset). Stop if credits run out.
**Token rules:** renders, stitching and measuring scripts run locally for free. `screen_capture` images sent to Claude are for framing checks only (about 10–20 per episode, plus the check sheet), never for measuring.

Episode folder: `<project>/projects/<episode>/` with `script.md`, `audio/vo.wav`, `words.json`, `shotlist.md`, `cue-sheet.md`, `edit/`, `QA.md`. Studio frames and parts live in the kit's own folders (`studio_kit/frames*/`, `parts*/`, ignored by git).

---

## Step 0. One-time setup
`SETUP.md`: `setup_windows.bat` (Python, Node, ffmpeg, Python packages), Roblox Studio MCP on, `studio_kit\start_bridge.bat`. Studio rendering settings and the quality call are in `studio.md` §2.

## Step 1. Script → `script.md`
Follow `script.md` and the `roblox-town-script` skill: rule in sentence 1, first word ≤0.2 s; twist family not used in the last 5 episodes; no banned phrases; it must sound like the user talking. Run `python tools/plan_timing.py --rewrite-times` and `python tools/script_check.py` on the sheet. Write the episode's row in `ROTATION-LOG.md` now (the 7 core fields of `templates/rotation-log.md` are mandatory), so the shot list follows it. **The user reads and edits the script before anything else happens.**

## Step 2. Voice + word timestamps
- ElevenLabs (settings in `audio.md` §1) or a free TTS voice. **Ask before generating** ("about N characters, 2 takes, OK?").
- Save `audio/vo.wav`. Set the designed pauses (script.md §6: the pause is the whole silence between the two words).
- Word timestamps, free: WhisperX / stable-ts forced alignment or faster-whisper (`captions.md` §3) → `words.json`. No paid transcription without asking.
- No credits at all: `tools/tts_sapi.ps1` (Windows voice, timestamps included; `audio.md` §1.1b).

## Step 3. Shot list + cue sheet + caption plan
From `script.md` + `words.json` with `templates/shot-list.md`, `templates/cue-sheet.md` (before the voice exists, use `plan_timing.py`'s `words_planned.json`). One row per shot, cut 1 frame before each sentence start (`pacing.md`), shot length, moves and look family per `look-reference.md`, a look-family shift on the twist cut (`lighting-color.md` §4). Run `python tools/shotlist_check.py shotlist.md`; fix every FAIL or write why. QA the plan with `checklist.md` (plan score ≥8 per area). The user reads the table before anything is built.

## Step 4. Build, animate, render in Studio
Everything in `studio.md`, in its §7 order, from a copy of `studio_kit/episode_template/` as the episode folder E: `python load.py --ep E` (kit through lib11 + the episode) → `MT.quality()` → clip scan → check sheet of every shot (`.\checks.ps1`) → `python fov.py --ep E` → `python render.py --ep E` → `python stitch.py --ep E --jobs 2` → `python join.py --ep E` (all in `studio_kit/`). Lighting: `assets/lighting/reference/lighting-<family>.lua`.
- **Tell the user the render time before starting.** Measured on E01 (2026-11-19, 39 shots, 63.6 s, 1,908 frames, 3,816 captures): 0.8-0.95 s per capture, about 60 min of capture plus a few minutes of stitching (run `stitch.py` while it renders); a 2.5 min episode ≈ 2.5 h. 4K is 3–4 captures per frame. Disk: about 0.9 GB of captures + 0.6 GB of stitched frames per minute of video; the final MP4 is about 100 MB.
- Before the full render, make a check sheet: `render.py --tiles 1 --n 1 --force` (one landscape capture per shot, about 1 min for 40 shots), centre-crop each to 9:16 and tile them. On E01 two rounds of this caught 15 framing problems (backs to camera, people hidden behind props, shots too wide, a building swallowing a sign).
- Episode layout (shots.json, lua/, audio/, frames/, out/): `studio_kit/episode.py`. Verified end to end on the 2-shot template on 2026-11-19 (load → fov → render → stitch → join → 1080×1920 30 fps MP4).
- Cast and movement: real R6 avatars + Roblox's R6 clips (`studio.md` §3.1, `studio_kit/lib10.lua`). Run `python studio_kit\rb.py lua studio_kit\r6_test.lua` once on a new PC and after Studio updates.

## Step 5. Edit
1. Checks on the caption-free picture: `python tools/move_check.py edit/picture.mp4 cuts.txt` (cuts.txt = the shot list's start times), `python tools/measure.py --video edit/picture.mp4 --times …` (colour), `python tools/pacing_check.py` (pacing.md §7).
2. Finish (captions, music, SFX) with the scripted route below; CapCut desktop (free) is the fallback when a scene needs hand trimming.

`join.py` applies the reference grade by default (contrast and saturation +6 %, vignette angle 0.24 = corner/centre 0.89 measured), before the captions; `--no-grade` turns it off. It also blends each frame lightly with its neighbours inside the shot (`--blur 0.2`, a cheap motion blur; `--blur 0` off).

**One click:** `python build_episode.py --ep <episode>` runs the machine parts of Steps 4–9 in order (see studio.md §3.2); add `--resume` to continue an interrupted render. Before it starts, the user must have read the script sheet and the voice must be final; a voice change means re-timing and re-checking the shot list.

## Step 6. Captions
Spec: `look-reference.md` §7 (1–2 words, lowercase white, soft shadow, one red ALL-CAPS key word, centre at 65 % height). Make `caps.ass` with `tools/make_caps.py` and the v3 flags in `captions.md` §0, burn in with ffmpeg. Colour tests always run on the caption-free picture.

## Step 7. Mix
`audio.md` §2–§4 and the cue sheet: voice 6–10 dB over the music, SFX on every action, music events on the reveal/power moments, duck ≥10 dB under quiet beats. Final file **−14 LUFS integrated, ≤ −1.0 dBTP** (limiter ceiling −1.5). Measure: `ffmpeg -i final.mp4 -af ebur128=peak=true -f null -` (read the summary at the end).

## Step 8. Export (one file for IG Reels and YouTube Shorts)
| item | value |
|---|---|
| Size / fps | 1080×1920, **30 fps constant** |
| Video | H.264 High, yuv420p, BT.709 tags, VBR about 12 Mbps (max 16), keyframe every 15 frames |
| Audio | AAC-LC, 48 kHz stereo, 320 kbps |
| Loudness | −14 LUFS integrated, ≤ −1.0 dBTP |
| Container | MP4 with `+faststart` |
| Length | ≤ 2:59 (UNVERIFIED today, recheck if it matters) |

```powershell
ffmpeg -i edit/picture_caps.mp4 -i edit/mix.wav -map 0:v -map 1:a `
  -c:v libx264 -profile:v high -pix_fmt yuv420p -r 30 -b:v 12M -maxrate 16M -bufsize 24M -g 15 `
  -color_primaries bt709 -color_trc bt709 -colorspace bt709 `
  -c:a aac -b:a 320k -ar 48000 -movflags +faststart -shortest final.mp4
```
(With an NVIDIA GPU, `-c:v h264_nvenc -b:v 12M` is faster.)

## Step 9. Disclosure and platform rules
- **Instagram**: turn on **"AI info"** when the narration is TTS or a voice clone. The user's own recorded voice needs no label.
- **YouTube**: animated (non-realistic) content and cloning one's own voice are listed as exempt from AI disclosure; a stock TTS voice in an animated video is probably exempt too (GUESS).
- **YouTube YPP "inauthentic content"**: don't put characters "in the same situation over and over again with the same outcome". The rotation log is the protection.
- **Roblox**: no Roblox logo anywhere; no implied endorsement; "Roblox" only in the description and hashtags (GUESS); no Roblox in-game music; no Classic/noob avatars. Recording Creator Store assets is a low-but-nonzero-risk grey zone every Roblox channel works in. Credit any CC-BY music (audio.md §5.3).

## Step 10. QA
Score the cut with `checklist.md` (every area ≥8, U1–U14 ≥10 met) and write `QA.md`. Update the episode's row in `ROTATION-LOG.md`.

---

## Build budget (per episode; HYPOTHESIS, replace with the first test's real hours)
| item | cap | how to stay under it |
|---|---|---|
| shots | about 1 per second of runtime (look-reference §4) | extra camera setups in an existing set are cheap; new sets, faces and moves are the cost |
| sets | ≤6, of which ≤2 new | the rest reused from earlier episodes, redressed (3 props + wall colours) |
| new face images | ≤40 | reuse the 24-face atlas from `make_faces_v2.py` first |
| rule-object images (signs, marks) | ≤12 uploaded images, counted from the shot list's props column | one sheet for a group; TextLabel signs on one SurfaceGui template don't count |
| special builds (a first-time trick) | ≤2 | a system built once is reused next time |
| new VFX | ≤3 | keep them for the next episode |
| outfits | 1 per character | `make_clothes.py` styles |
| crowds | spaced ≥4.4 studs (studio.md §4), soft in DOF, ≤3 of them moving | |

Anything over a cap needs a reason and the user's OK.

## First test: 15 s end to end (do this before a full episode)
Cost $0 (the user records the lines on a phone or uses an existing take). Pass if: MCP connected and `list_roblox_studios` returns an id; `r6_test.lua` passes; one set + 2 characters + 15 shots built; clip scan empty; check sheet approved; tiled render sharp next to a ref frame; `move_check.py` ≥55 % moving; captions + mix + export pass the numbers above. Write the real minutes per stage and seconds per capture into this file, replacing ESTIMATE / UNVERIFIED.
