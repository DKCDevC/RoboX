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
- **Default: `tools/tts_edge.py` (Andrew, `+45 %`, `+25Hz`: free, word timestamps included, `audio.md` §1.1c).** ElevenLabs (settings in `audio.md` §1) only when the user asks; **ask before generating** ("about N characters, 2 takes, OK?").
- Save `audio/vo.wav`. Set the designed pauses (script.md §6: the pause is the whole silence between the two words).
- Word timestamps, free: WhisperX / stable-ts forced alignment or faster-whisper (`captions.md` §3) → `words.json`. No paid transcription without asking.
- No credits at all: `tools/tts_sapi.ps1` (Windows voice, timestamps included; `audio.md` §1.1b).

## Step 3. Cast → Set → Storyboard (three gates; the user approves each before the next starts)
The build is split into four stages, each ending in a sheet the user looks at. Nothing is rendered until the first three are approved (`build_episode.py` checks; `stage.py` records it). `python studio_kit/stage.py --ep E init` creates `E/stage/`, `E/cast.md`, `E/sets.md` and `E/stages.json`; `stage.py status` shows what is done and what is next. Start from a copy of `studio_kit/episode_template/` as the episode folder E, `python load.py --ep E`, run `r6_test.lua` once per PC, then:

**Stage 1. CAST** (`templates/cast.md`). Read the script and list every character: role, age, outfit, hair, face set, voice, the planted object's carrier. Build them in Studio (real R6 avatars, `studio.md` §3), check hair against the eyes, give each a different silhouette and main colour. Capture each front and 3/4 with three key faces, tile with `stage.py sheet` into `E/stage/cast_sheet.jpg`. The user approves: `stage.py --ep E approve cast`.

**Stage 2. SET** (`templates/sets.md`). List the locations (≤6, ≤2 new), their look family, **one dominant hue per location**, the colour script with the palette change at the story turn, the rule object and signs. Build and light them (`studio.md` §6, `lib13_sets.lua`, `assets/lighting/reference/`), put the cast who appear in each, capture a wide, a low close angle and a top-down per set into `E/stage/set_<name>.jpg`. Approve: `stage.py --ep E approve set` (needs the cast approved).

**Stage 3. STORYBOARD** (`templates/shot-list.md`, `templates/cue-sheet.md`). Only now plan the shots, **on the real cast and sets**, from `script.md` + `words.json` (before the voice exists use `plan_timing.py`'s `words_planned.json`, then redo it from the real one). One row per shot: line, camera size/angle/move (push-in on ≥ 75 %, Dutch roll on about 28 %), character action (about half of the shots), set, look family, caption, cut 1 frame before each sentence start (`pacing.md`: 7–10 cuts per 10 s, mean shot 1.1–1.4 s). Fill `E/shots.json` and `E/lua/shots.lua`, run `python tools/shotlist_check.py shotlist.md`, `stage.py status` (it prints the pacing of the planned cuts), and QA the plan with `checklist.md` (plan score ≥ 8 per area). Capture **frame 1 (and the last frame) of every shot** with `.\checks.ps1` or `render.py --tiles 1 --n 1 --force` (one landscape capture per shot, about 1 min for 40 shots; centre-crop to 9:16) and tile them into `E/stage/storyboard_a.jpg ...`. On E01 two rounds of this caught 15 framing problems (backs to camera, people hidden behind props, shots too wide, a building swallowing a sign). Run the clip scan on every shot, and read the `SLOW WALK` notes. The user approves: `stage.py --ep E approve storyboard`.
A change after approval: `stage.py revoke <stage>` (it also revokes the stages after it), fix it, show the new sheet, approve again.

## Step 4. RENDER in Studio
Everything in `studio.md`, in its §7 order: `python build_episode.py --ep E` runs sync textures → load → `fov.py` → `render.py` → `stitch.py` → captions → `join.py` (add `--resume` after an interruption; it stops at once if the three approvals are missing, `--skip-gates` overrides for old episodes). By hand: `python load.py --ep E` → `python fov.py --ep E` → `python render.py --ep E` → `python stitch.py --ep E --jobs 2` → `python join.py --ep E` (all in `studio_kit/`).
- **Tell the user the render time before starting.** Measured on E01 (2026-11-19, 39 shots, 63.6 s, 1,908 frames, 3,816 captures): 0.8-0.95 s per capture, about 60 min of capture plus a few minutes of stitching (run `stitch.py` while it renders); a 2.5 min episode ≈ 2.5 h. 4K is 3–4 captures per frame. Disk: about 0.9 GB of captures + 0.6 GB of stitched frames per minute of video; the final MP4 is about 100 MB. At 7–10 cuts per 10 s there are more shots than before, so count the shots from `stage.py status`.
- Keep the PC awake with the Studio window maximised and uncovered, the mouse off the 3D view (`preflight.py` checks and fixes it); `build_episode.py` keeps the display on while it waits.
- After the render, scan the stitched frames for blank or glitched frames before the join (`SKILL.md` known mistakes).
- Episode layout (shots.json, lua/, audio/, frames/, out/, stage/): `studio_kit/episode.py`. Verified end to end on the 2-shot template on 2026-11-19 (load → fov → render → stitch → join → 1080×1920 30 fps MP4).

## Step 5. Edit
1. Checks on the caption-free picture: `python tools/move_check.py edit/picture.mp4 cuts.txt` (cuts.txt = the shot list's start times), `python tools/measure.py --video edit/picture.mp4 --times …` (colour), `python tools/pacing_check.py` (pacing.md §7).
2. Finish (captions, music, SFX) with the scripted route below; CapCut desktop (free) is the fallback when a scene needs hand trimming.

`join.py` applies the reference grade by default (contrast and saturation +6 %, vignette angle 0.24 = corner/centre 0.89 measured), before the captions; `--no-grade` turns it off. It also blends each frame lightly with its neighbours inside the shot (`--blur 0.2`, a cheap motion blur; `--blur 0` off).

**One click:** `python build_episode.py --ep <episode>` runs the machine parts of Steps 4–9 in order (see studio.md §3.2); add `--resume` to continue an interrupted render. Before it starts, the user must have read the script sheet and the voice must be final; a voice change means re-timing and re-checking the shot list.

## Step 6. Captions
Spec: `captions.md` (one word per caption, white with a black outline, no red key word, centre about 68 % height, normal capitalisation); the E01–E03 look is in `legacy/captions-older-looks.md` and `build_episode.py --old-caps`. Make `caps.ass` with `tools/make_caps.py` and the flags in `captions.md` §1, burn in with ffmpeg. Colour tests always run on the caption-free picture.

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
