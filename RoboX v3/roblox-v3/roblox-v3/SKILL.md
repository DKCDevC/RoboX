---
name: roblox-v3
description: Make Roblox 3D story reels/shorts (vertical, 60 s–3 min, first-person narration) in the reference look measured frame by frame: saturated sunny sets, real R6 avatars with custom expressive faces, characters walking and running, push-ins, shake, depth of field, fast ~1 s cuts, small lowercase captions with one red key word. Covers script, voice, captions, pacing, camera, lighting files, faces, movement and the Roblox Studio build on Windows. Use for ANY Roblox-look story video when the user asks for roblox v3 or the reference style.
---

# Roblox story reels (v3: reference look; docs consolidated 2026-11-19)

**One look, one build route.**
- **Look = `look-reference.md`. Read it first.** Measured from every frame of 5 reference Shorts (34,398 frames, 660 shots). Its §10 is the single list of older numbers it replaces in `look.md`, `lighting-color.md`, `pacing.md` and `captions.md`; everything else in those files still applies.
- **Build = Roblox Studio on Windows, driven by Claude through the Studio MCP** (`studio.md`), with free Creator Store assets and the kit in `studio_kit/`. Lighting: `assets/lighting/reference/lighting-<family>.lua`.
- **Script shape:** the `roblox-town-script` skill and `script.md`.
- `legacy/` holds the retired routes (Blender kit, the Mac shot-runner + OBS pipeline, Moon Animator notes, the bright-toon style). Don't read it unless the user asks for one of those.

The research behind the rules lives outside the skill; every number you need is inside these files. Paths like `<project>/…` mean the user's own project folder.
Tags inside the files: **REF-RANGE** = measured on the refs · **HYPOTHESIS** = a beat-the-refs bet; keep it only if the user's analytics agree · **POLICY** = a platform or legal rule.
The refs are the floor. Every episode must also pass `upgrades.md` (≥10 of 14).

## Files
| file | use it for |
|---|---|
| `look-reference.md` | **the target look**: 6 look families with measured numbers, camera grammar, edit rhythm, faces, movement, captions, effects, never-do list, **§10 overrides** |
| `assets/lighting/reference/` | one Studio command-bar lighting file per look family |
| `script.md` | world-rule formula and scoring, beat map by % for any 60–180 s runtime, twist families, sentence rules, **the pause rule** (§6), banned phrases, self-check |
| `studio.md` | **the build**: Studio MCP + bridge, tiled 1080x1920 / 4K capture, R6 characters with clothes, hair fit, the two cast routes (§3.1), no-clipping, physics, order of work (§7) |
| `pipeline.md` | the whole episode in order on Windows: folder, script, voice, shot list, build, edit, captions, mix, export, disclosure, QA, build budget, first test |
| `look.md` | shot sizes, angles, the first shot, showing the rule on screen, sets, signs, ending shot, continuity (numbers per look-reference §10) |
| `lighting-color.md` | colour script of an episode, twist colour shift, practicals, measuring a capture (numbers per look-reference §10) |
| `pacing.md` | cuts on sentence starts, hook, pauses, holds (shot lengths per look-reference §10) |
| `captions.md` | §0 = v3 caption spec + `make_caps.py` flags; timing, accents, safe zones |
| `audio.md` | ElevenLabs voice settings, pauses, character voices, music events, SFX, mix targets, library map, rotation |
| `upgrades.md` | the 14 upgrades over the refs + what to rotate every episode |
| `checklist.md` | QA rubric, /10 per area; anything under 8 gets fixed |
| `SETUP.md` | one-time free install on Windows (`setup_windows.bat`, Studio MCP, bridge) |
| `templates/` | script sheet, shot list, cue sheet, **rotation log**, hero cast file, caption preset |
| `examples/` | 2 gold scripts: a quality comparison **after** your first draft. Never open them before (they anchor: round 2 rebuilt gold-1 beat for beat) |
| `tools/` | zero-token Python: `script_check.py`, `plan_timing.py` (sheet → planned words.json + cuts.txt), `shotlist_check.py`, `pacing_check.py`, `make_caps.py`, `move_check.py`, `measure.py` (colour); `sheetlib.py` is their shared parser; `patterns.txt`, `skeletons.txt` are their data |
| `studio_kit/` | `bridge.mjs` + `start_bridge.bat`, `rb.py` (run Luau / capture), `lib*.lua` (the MT kit), `make_faces_v2.py`, `make_clothes.py`, render/stitch/join scripts, `checks.ps1` |
| `agents/` | the 8 research-team agents, to rerun when new reference videos are added |
| `legacy/` | retired: `blender.md` + Blender kit, `style-toon.md`, `pipeline-obs-mac.md` (shot runner + OBS), `mcp-setup.md` tests, `lighting-presets.lua`, `make_caps_toon.py`, `assemble.py` |

**What to read.** Planning an episode (script, shot list, cue sheet, caption plan): `look-reference.md`, `script.md`, `templates/`, `checklist.md` [plan] items, the tools, `look.md` §0–3, §5, §6, §9, §16, `lighting-color.md` §4–5, all of `audio.md`, `pacing.md` §2–5, `captions.md` §0–1, and `pipeline.md` (steps + build budget). Building: `studio.md` (and `SETUP.md` once). Editing: `pipeline.md` steps 5–10. Paths outside the skill (`<project>/…`) may not exist in your session: a log or cast file supplied in the brief replaces them.

**Fallbacks.** No Agent tool: the blind guess test is UNCHECKED; leave `pretwist.txt` for the orchestrating session or the user to read. No `humanizer` skill: do script.md §10 step 7's six-item pass by hand.

## Workflow (always in this order)
1. **Rule.** Write 5 one-sentence world rules and score each with the script.md rubric. Keep the best one that's outside the crowded "X is deadly" lane.
2. **Rotation.** Read the last 5 rows of `<project>/projects/ROTATION-LOG.md` (fields and rules: `templates/rotation-log.md`). Twist family not in the last 5; reveal ≥10 points from the last episode. A field the log doesn't have yet is free: choose and log it.
3. **Script.** Rule, beat map, 10-slot skeleton and tone (script.md §0.2, §9.4), then the first draft, **all before opening `examples/`**. Only then compare with the golds for quality. Then the humanizer pass, `tools/plan_timing.py`, `tools/script_check.py` (with `--log` and `--pretwist`) and the blind guess test (script.md §3.3), in `templates/script-sheet.md`. **The user reads it and edits before any voice is generated or anything is built. Never skip that read.** A plan package may draft steps 5–6 on planned timing before the read; mark it "waiting on the user's read".
4. **Voice.** ElevenLabs voice (or a free text-to-speech voice). **Ask before spending credits** (character count from `script_check.py`). Get word timestamps (WhisperX / faster-whisper), then set the designed pauses (script.md §6).
5. **Shot list + cue sheet + caption plan** from the timestamps (`templates/`). For a plan, use `plan_timing.py`'s planned words.json, then rebuild from the real one.
6. **QA the plan** with checklist.md: the plan score (a) must be ≥8 in every area, no HARD fail.
7. **Build** in Roblox Studio (`studio.md` §7 order): world, light file, cast (§3.1 route), moves, clip scan, check sheet of every shot.
8. **Render** with `studio_kit\start_bridge.bat` + `render2.py` → `stitch.py` → `join.py`. Tell the user the render time first. Run a 15 s end-to-end test before the first full episode (`pipeline.md`).
9. **Edit** (`pipeline.md` steps 5–8): checks, captions from timestamps, music events, SFX, mix to −14 LUFS, export.
10. **QA the cut** with checklist.md: the strict score (b) must be ≥8 in every area. Then export. IG "AI info" label on when the narration is a TTS/clone. Update the episode's row in ROTATION-LOG.md.

## The 21 rules that matter most (reference look; numbers from look-reference.md)
1. The rule/premise is the first sentence, spoken at 0.0–0.2 s, 8–15 words, fully clear by about 9 % of runtime. (REF)
2. Reveal at 49–78 %, climax 69–96 %, last line at ≥92 %. No outro. (REF)
3. Rotate twist families. Never default to "secret sacrifice for a sick or dying relative". (POLICY + REF)
4. Banned outright: "for the first time", "I finally understood/knew", "Everyone thought…", emphasis-only fragments. (REF)
5. Short sentences: about 5–7 words, half of them 6 words or fewer. Every fragment adds a new fact. (REF)
6. Narration 185–240 wpm. Exactly 2–3 designed pauses (after the twist, before the last line). (REF)
7. Music changes with the story: calm bed → tension → big power/reveal hit. Duck ≥10 dB under quiet beats. (REF)
8. SFX on every action: whooshes on push-ins and runs, impacts with shake, a glow/rise sound on powers and flashes. (REF)
9. **Fast cuts:** median shot 0.9–1.1 s, 8–12 cuts per 10 s, nothing over 2.5 s except one designed hold. Cut on sentence starts. (the reference)
10. Rule/premise object in shot 1 and in ≥50 % of shots. **Big readable in-world signs** carry the facts (prices, names, "SIGN UP HERE"), text in the top third. (the reference)
11. **Faces:** real R6 avatars with custom faces: big white eyes with pupils, thick angled brows, open mouths with teeth, sweat. A new face on almost every shot; reaction faces 0.5–1 s. Characters fill the frame on close-ups. (the reference)
12. **Camera:** push in on about 40 % of shots (many are big 5–15 % punch-ins), static camera with a moving character on about 15 %, pull out on about 10 %, shake on about 25 % (impacts, runs, powers), roll on hits. Low angles, wide lens, **depth of field ON for close-ups** (soft background). (the reference)
13. **Lighting:** run `assets/lighting/reference/lighting-<family>.lua` for the scene's mood (mid-neutral-normal for normal life, mid-warm-vivid for golden/power, dark-neutral-vivid for blue tension, bright-warm-vivid for gold glory, dark-warm-vivid for lava/danger, bright-neutral-normal for heaven/flash). Video averages: brightness 0.34–0.43, saturation 0.42–0.66, near-pure blacks, slight vignette (~0.89). Bloom on gold, wings and powers. White flash frames on reveals. (the reference)
14. Custom hero with our own face decals. Never the noob or classic avatar (Creator Terms), no Roblox logo, Roblox audio muted. Never copy reference characters, outfits, names or stories. (POLICY)
15. **Captions:** 1–2 words at a time, lowercase, white, bold rounded sans, soft dark shadow, cap height about 50 px, centered at about 65 % of the height. One key word per sentence in ALL-CAPS red (about #e8452c). Mix: −14 LUFS, ≤ −1.0 dBTP, voice 6–10 dB over music. (the reference)

16. **Nothing passes through anything.** No arm inside a torso, no person inside another person, no body inside a wall, table, bed, lamp or tree, no prop sunk into a hand. Run the clip check on every shot (first, middle and last frame) before rendering; it must be empty or explained. (the user, 2026-11-14)
17. **Hair and hats never sink into or float off the head.** Scale the head the same on every axis and put accessories on their own attachment at the same scale. (the user, 2026-11-14)
18. **Real physics.** Thrown things arc and spin, dropped things fall and bounce, feet stay planted on the floor, walkers move at walking speed, nobody slides or floats. (the user, 2026-11-14)
19. **Sharp picture.** Native 1080x1920 frames (tiled capture), max quality level, never a stretched centre-crop. Compare one frame side by side with a ref before the full render. (the user, 2026-11-14)
20. **Characters look like real Roblox avatars:** R6 with real shirts and pants (collars, hoodies, prints, jeans, shoes), real hair accessories, crowd spacing ≥4.4 studs. Never plain coloured blocks. (the user, 2026-11-14)
21. **Characters move.** Something moves on its own in about 63 % of screen time; about a third of shots have someone walking or running (real R6 walk/run animations, big arm swings). Use: running straight at a low static camera until he fills the frame, walking across frame, entering and leaving frame, being grabbed, falling, flying. Feet stay on the ground with hard sun shadows. 

## Never
- Spend ElevenLabs/Higgsfield credits, buy plugins or assets (Moon Animator included), or use paid add-on features (Meshy/Tripo/Rodin/World Labs) without the user's OK.
- Copy a ref's story, music track, opener sound or avatar, or a line shape from the refs or golds (script.md §9.4).
- Use the refs' bad data fields as evidence (`shots.json` move labels, `audio.json` music_changes/sfx_hits).
- Hand the user a script that fails the script.md self-check (voice, logic and twist tests included), or count an unchecked item as a pass.

## Known mistakes (add here when a review note repeats)
- Never hand the user one still frame per shot with a camera zoom as "the video". Every shot must be animated in Roblox Studio (breathing, blinks, talking mouths, reactions, walks, camera move). Working pattern: `studio_kit/start_bridge.bat` / `render2.py` with per-frame moves (studio.md §3.1). If time is short, say so before building, not after.
- Never render a centre 9:16 crop of a landscape Studio capture (about 590 px wide, then stretched). It looked blurry next to the refs. Use the tiled capture in `studio.md` §2.
- Never stretch the head unevenly (old 2.0×1.75×1.8 head). The hair sank into it. The head scales the same on every axis, and the hair uses the same k.
- Never pack people closer than R6 shoulders allow (2.6-stud crowd grid = bodies inside bodies). Use ≥4.4 studs, and let `MT.resolve` push the crowd out of the cast.
- Never build a character from plain boxes (box sleeves, box shoes, no clothes). the user: "my roblox guys are looking really bad".
- Never ship camera moves + face swaps on standing bodies (ep02 "no animation?", 2026-11-16). Our rigs are anchored parts (no Motor6Ds), so use a walk/run cycle (the original `ep_anim.lua` was not shipped; write it, or take studio.md §3.1 route B): phase from distance travelled (feet planted, no sliding), legs ±40° walk / ±60° run, opposite arms ±44°/±72°, hip drop so the tilted leg stands on its edge. The missing `ep_moves.lua` covered idle life on every rig, talking hands, gestures, reactions, flailing, capes, walkers and moving bits for empty inserts. Check with `tools/move_check.py`: ≥55 % of frames moving, no still shot.
- Studio can close mid-render (update or crash). Check `bridge.log` for "No studio available" and follow the recovery steps in `studio.md` §1.
