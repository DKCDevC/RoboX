# gneef-study.md: what the @Gneef Shorts do (measured 2026-11-20)

**Source (batch 1, 2026-11-20).** The five newest Shorts of the YouTube channel @Gneef (2.21M subscribers, Roblox "In this town..." stories), uploaded 2026-11-18 to 11-20: *Fishing*, *The Worm*, *One Child Only*, *Magic 8-Ball*, *The Bounty Hunter*. Downloaded in 4K, studied at 30 fps (the two 60 fps files resampled to 30), 576 shots, about 12 minutes of picture. Local copies were for this study only. Tools: `tools/ref_cuts.py`, `tools/ref_motion.py` (the cut detector found 35 cuts on E03, true count 33). Whisper `small.en` for the words.
**Status.** REF-RANGE with n = 5 videos from one channel. Folded on 2026-11-20 into the skill's own rules as the **single current set of numbers**: `look-reference.md` (§2–§10), `pacing.md`, `captions.md`, `lighting-color.md`, `audio.md` §1.2, `script.md` §3.5 and §6, `SKILL.md` rules, and the kit/tools (`join.py` no vignette, `def.roll`, `make_caps.py` defaults, `script_check.py` / `pacing_check.py` `--mode fast|slow`). No episode has been built to it yet; §8 lists the changes and E03's numbers beside them.

## 1. Format
- 2160×3840 vertical, 30 fps (3 of 5) or 60 fps (2 of 5), 122–154 s. 535–698 words per script.
- Every script opens with its rule as sentence 1, from the first frame: "In this town / world / galaxy, ...". Sentence 2 usually starts "You see," and explains the rule.

## 2. Cuts (per video, 94–136 cuts)
| | Gneef | E03 |
|---|---|---|
| cuts per 10 s | **7.1–8.8** | 4.8 |
| mean shot | **1.13–1.40 s** | 2.04 s |
| median shot | 1.10–1.25 s | 2.03 s |
| shots under 1 s | 26–39 % | 6 % |
| longest shot | 2.8–5.6 s | 3.9 s |
- Cut density is even across the runtime (about 25 % of the cuts per quarter), including the first 3 s (2–4 cuts) and the last 10 s (5–11 cuts). No slow patches, no long holds.
- Cuts follow the narration: 57–82 % of sentence starts get a cut within 0.15 s, and cuts fall 0–0.12 s before a sentence start 3–5× more often than chance. The rest cut inside sentences at clause breaks. About 5 words per shot (260 wpm × 1.2 s).

## 3. Camera and movement (optical flow, per shot)
- **Push-in in 77 % of shots** (65–88 % per video), median zoom rate about 6 % per second, top 5 % faster than 29 % per second. Pull-outs 9 %. Only **6 % of shots are still**.
- **Roll (a Dutch tilt that turns during the shot) in 29 %**, up to 40 % on horror and action videos. Pans are rare (8 %). Handheld-style shake in 14 % (30 % on the action video), mostly with impacts.
- Characters move in about half of the shots (running, climbing, flinching, turning): animation is continuous, not poses.
- Angles are extreme and varied: face close-ups filling the frame, straight top-down, worm's-eye, wide-FOV distortion, objects passing close to the lens. Subject sits low or centre, a face or object fills 40–100 % of the frame in many shots. A map or reveal gets one wide shot, then cuts back in.
- No exposure flashes (none found in any video); impacts are cuts plus shake and push.

## 4. Light, colour, contrast
| | Gneef (5 videos) | E03 |
|---|---|---|
| mean luma (0–255) | 95–123 | 83 |
| contrast (luma std) | 47–65 | 48 |
| saturation | 0.49–0.70 | 0.74 |
| darkest 1 % / brightest 1 % | 3–27 / 193–219 | 3 / 200 |
| corner ÷ centre brightness | 0.96–1.27 (no vignette) | 0.93 |
| warm bias (R − B) | **+0.09 to +0.27** | −0.05 |
- **One dominant colour per location, and the whole palette changes at a story turn.** Examples seen: amber/teal desert with orange dust; purple-orange dusk square with a cyan glowing 8-ball; warm orange interiors against deep-blue night streets; the underwater ghost world graded fully cyan-green; a bright pastel daytime town that turns deep blue for the monster. Complementary warm/cool pairs inside one frame (amber light on faces, blue ambience behind).
- **Deep blacks are allowed** (night shots go to 3/255) next to bright skin and neon. Interiors are warm tungsten, practical lamps and windows lit.
- Depth: strong depth of field on close-ups (soft background), fog and haze in horror, light shafts, dust/snow/spark particles, bloom on neon and glow (the 8-ball face, cards, lamps). Hard sun shadows in the day town.
- No vignette: do not darken the corners.

## 5. Captions
- **One word at a time**, switching on every spoken word (about every 4–8 frames at 30 fps), centred horizontally, at about **68 % of the frame height**.
- Bold rounded sans, **white**, thick black outline plus soft shadow, about 85 px font at 1080×1920 (ascender about 60 px). No coloured key word in these five.
- Capitalisation follows the text: "I", names, "Mr", "Sunday", times like "3:00am" keep their case; ordinary words are lowercase.

## 6. Voice and audio
- **248–271 wpm** (a fast voice, continuous). No designed silences: in the three videos checked (8-Ball, One Child Only, Fishing) the mix has 0–1 silences of 0.12 s or more at −30 dB, and whisper finds at most one word gap of 0.5 s or more per video (0.5–2.1 s). Punches are carried by short sentences, not pauses.
- Mix about **−17 LUFS** integrated, LRA 3–4 LU, peaks −0.4 to −0.8 dBFS (measured on the same three videos; E03 is −14.1; the platform normalises both).
- A continuous music/ambience bed under the voice (nothing drops to silence). Sound effects could not be separated from the bed in the mix; treat them as unmeasured.

## 7. Script structure (summarised, not quoted)
- **Hook (0–10 s):** the rule in one sentence, a vivid impossible thing with a number or size ("as big as a house", "never failed in 300 years"), then the rule's mechanics in 2–3 sentences.
- **Narrator and anchors by about 10 %:** age line ("I'm 17") or a job, then one best friend or sibling and a parent, each with one concrete trait or object (a compass, a grease pencil behind the ear, a notebook, cinnamon rolls). These objects come back as the payoff.
- **Inciting event at 20–27 %:** a time marker ("one night", "in the spring", "this spring", "last Tuesday", "in April") and a first escalation.
- **Middle (30–60 %):** each step raises the stakes with a concrete, sensory detail (wet black fur, rings of teeth, tubes like veins) and a new place on the map. Rule logic is used, not just stated: the narrator finds the loophole in the rule's wording or the rule turns on them.
- **Twist / reveal 36–60 %** (a name in the notebook at 36 %, "my twin brother" at 60 %, the rule's trick at 48–59 %), then a **second turn at 80–90 %** (the narrator is the one erased / the worm's target is them / the ending sacrifice).
- **Ending (last 5–8 %):** a callback to a line planted early (the mother's lullaby line, the rule repeated as advice, the bounty hunter waiting at the finish line), or a cliffhanger on the best friend's face. Last line short, concrete, no moral.
- Sentences average about 9–12 words (7.0–12.4 per video), mixed with 2–4 word punches ("I ran."). Present-tense world, past-tense story. Family or friend stakes (a sibling, a mother, a best friend) in four of five. Three end warm, funny or triumphant, two end dark.

## 8. Gap to E03 and what to change (now the defaults in `look-reference.md`; each still needs a render to prove)
1. **Cut faster:** target 7–9 cuts per 10 s, mean shot 1.1–1.4 s, few shots over 3.5 s (0–4 per video, none over 6 s). E03 runs 4.8. At 260 wpm that is about 5 words per shot.
2. **Push almost every shot** (≥ 75 %), not 37 %; stills at most 6 %. Add roll (Dutch turn) to about 25–30 % of shots and keep it for tense beats.
3. **Make the characters act in about half of the shots** (E03: 34 %); no pose-and-hold.
4. **Colour per location with a hard change at the turn;** warm bias +0.1 to +0.25 for day and interior scenes, deep blue allowed at night, and **remove the vignette** (E03's grade adds one: corners 0.93 vs 0.96+). Raise mean luma from 83 toward 100–120 in day scenes; keep saturation 0.5–0.7 (E03 is 0.74, already high).
5. **Captions: one word per caption**, 68 % height, white + black outline, normal capitalisation (E03: 1–2 words, lowercase, one red word).
6. **Voice 250–270 wpm** (E03: 186 at +15 %; about +55–60 % with tts_edge, see `audio.md` §1.1c / §1.2b), continuous, no designed pauses. Check against `script.md` §6 (the pause rule) before adopting; that rule is from the six older refs.
7. **No exposure flashes;** use cuts plus shake and push on impacts.
8. Script: keep the E03 formula (rule in sentence 1) and add the age line, two family or friend anchors, one planted object that pays off, a time marker for the inciting event, a twist by 36–60 % and a second turn by 80–90 %, and an ending that calls back a planted line. Mind the rotation log: do not copy a story, only the structure.

## 9. Method notes and limits
- Cut detection: mean absolute difference of 54×96 greyscale frames; a cut is a frame-to-frame jump above 9 grey levels and 4.5× the local median. It misses slow dissolves (none seen) and can double-count a fast whip.
- Motion: Farneback optical flow at 135×240, zoom and roll from a least-squares fit of the flow field. Rates are in fractions of the frame per second; thresholds in `ref_motion.py` calls above are push > 0.025/s, roll > 0.03/s.
- Audio words come from whisper `small.en`; timings are good to about 0.1 s. Loudness from `ffmpeg ebur128` on the original files.
- Five videos from one channel on three days: a recent snapshot, not a rule. Re-run the tools when the channel changes.

## 10. Why our frames looked cheap next to his (frame-by-frame comparison, 2026-11-20) and what changed
Compared matching frames at native 4K and by numbers (`tools/ref_look.py`). **There is no ink outline pass** in his videos (checked at 4K): the "drawn", premium feel comes from the points below. Median of 3 videos, ours = the first ep04 render:

| metric | @Gneef | ours before | ours after (v3.2) |
|---|---|---|---|
| mean luma | 0.38 | 0.52 | 0.37 |
| share of pixels with saturation > 0.8 | 0.22 | 0.49 | 0.19 |
| saturation | 0.59 | 0.70 | 0.52 |
| warm bias (R − B) | +0.24 | −0.44 | −0.19 (sky still blue in some shots) |
| hue entropy (fewer = one palette) | 1.2 | 1.7–2.1 | 1.5–2.0 |
| local texture (Laplacian) | 1.8 | 1.3 | 1.3–1.4 (still low) |

Causes found, in order of effect:
1. **Environment was flat plastic** (SmoothPlastic boxes, wedge "mountains", pure-colour ground). His surfaces have real texture everywhere (wood grain, brick, rust, knit, foliage) and layered depth. Fix: `lib15_world.lua` (terrain lawn, textured parts, hills in haze, trees, fences, lit windows, warm lamps), `MT.townStreet`.
2. **Colours screamed**: ColorCorrection saturation +0.34..0.57 on top of pure-primary part colours, a blue ambient filling every shadow, noon sun. Fix: the art grade in `lib11.lua` (`MT.ART`): ambient ×0.7 pulled warm, saturation 0.2, warm tint, exposure −0.3, contrast 0.24, low `EnvironmentDiffuseScale` (the sky is blue, so it tints everything).
3. **Flat front light on faces.** His heads have a warm key from one side and falloff. Fix: `MT.portraitLight` (warm key + cool rim) runs for every `MT.camOn` shot.
4. **Time of day.** A high noon sun and a big cobalt sky read as a game screenshot. Fix: golden hour with the sun **low and behind the scene** (`MT.ART.sunDir = {0.25, 0.9, 0.2}`, shot +y is where most cameras look): glow in frame, long shadows, rim light, orange haze (`Atmosphere.Decay` tints the sky at dusk).
5. **Flat clothes.** His shirts have knit and folds. Fix: `studio_kit/fabricize.py` (knit pattern, grain, dye mottling, fold shading, calmer colour) on the templates; copy to a **new** textures folder.
6. **Still open:** texture density at distance (needs more set dressing and PBR assets), the faces (ours are bolder and larger than his), the head and body proportions, blue sky in shots that look away from the sun, the night sky (black).
Pitfalls found: terrain voxels are 4 studs (a block topped at y = 0 came out at +2: use centre −7 for a 10-stud block); `Terrain.Decoration` grass blades fill the lens at low angles (turn it off); terrain Asphalt reflects the sky like water (use an Asphalt **part**); a green signal PointLight tinted skin and hair green (small range); `join.py --blur 0.2` ghosted a fast walk (default now 0.1); `MT.ART.on = false` restores the old look.

## 11. Batch 2 (2026-11-20): five more Shorts, 10 in all
*The Watcher's Knot* (30 fps), *The Red Circle* (30 fps), *Twin Brother*, *City of Halo*, *Unmasked* (60 fps, resampled to 30; 4K except Unmasked at 1080p), 642 shots, 114–178 s. Same tools. **Everything in §2–§9 held**, with these updates (10 videos, 1,218 shots):

**Cuts and camera.** 7.7–10.6 cuts per 10 s (mean shot 0.94–1.29 s; *Twin Brother* is the fastest at 10.6 per 10 s, 62 % of its shots under 1 s). Push-ins in 75–89 % of shots (81 % in this batch), **roll in 34–66 % (44 %; *City of Halo* 66 %)**, still shots 1–7 %, shake 10–31 %, characters acting in 51–72 %. Over both batches: push 79 %, roll about 37 %, still about 4 %, shake about 18 %, acting about 56 %. No flashes, no vignette again (corner ÷ centre 0.80–1.33).

**Voice and script.** 242–276 wpm (batch 1: 248–271); 522–718 words; sentence mean 7.0–12.4 words over all ten (the very short *Twin Brother* is 7.0 at 276 wpm). All five open "In this city / town / house / world, ..." with "You see," in sentence 2 (10 of 10 overall). New structure facts:
- **A flash-forward teaser can sit in the hook:** "Last night, my dad's mask fell off." at 5 % (*Unmasked*) is answered at 50 %. A rule can be told as a short list ("Mom has three rules", 13 %).
- **Narrator's name and age come as a flat fact, even late** ("My name is Reese. I'm 12." at 36 %; "for 11 years"). The two anchors (a parent, a best friend or twin) are in all five.
- **Time markers drive the middle** ("last Tuesday", "the next night", "day nine, day fourteen, day twenty"), a ritual or counter the narrator keeps (the watchbook, tally marks, one note per night).
- **Planted object or line, paid off twice:** the watcher's knot ("only you and me know this one") unties the lock, then ends the story; the tally-mark ring piece on the shelf is the proof of the twist; "stay on our side, sweetheart, and never wave back" opens and closes the story.
- **Beats again:** inciting 17–22 %, first reveal 47–52 %, second turn 78–89 %, last turn at 93–98 %. Endings: one triumphant, two bitter-sweet (the narrator chooses to go back for the baby / loses the friend), two dark (the narrator replaces the sibling / is put in the ring).
- Every video has an **impossible, visual rule with a number or size** (a city 300 feet up, a red line where one day inside is a year outside, 23 masks, 100 years of sleep, a twin in the walls).

**Art direction (new, important for our look).**
1. **The palette is the story's idea.** *The Red Circle*: the town is built and dressed in greys (mean saturation 0.32, texture still 2.1), the red line and the world outside are saturated. *City of Halo*: the Undercity is a neon night (magenta and cyan on dark panels, hue entropy 2.5, luma 0.30), Halo is white towers and gold sun. *The Watcher's Knot*: gold and orange wood (saturation 0.85, 72 % of pixels above 0.8, warm +0.40) with a **complementary green glow** from the sleep chests' frosted glass. *Unmasked*: warm gold interiors and a green fog outdoors. *Twin Brother*: a warm cream and orange house, soft and bright. So saturation and hue count are **per story**, not one number for the channel.
2. **Neon is real neon**: Neon-material bars and signs with readable text ("RAMEN", "BOTS") on near-black panels, with a bloom halo; the rest of the street is dark and textured.
3. **Skin and hair**: warm key light and bloom push faces toward bright cream-yellow, hair is a flat, slightly glowing orange; faces are minimal (dot eyes, a curved mouth, one brow). **One recurring hero** (orange hair, cream sweater, brown coat) in all ten videos; side characters are simpler.
4. **Readable text props held to the lens**: a note with the plot line ("My name is Theo..."), a bracelet box ("TWIN B"), a sign ("No Mirrors"), a wall of masks with years, tally marks, a calendar. Close-ups of props are as common as faces.
5. **Bespoke sets per story**: hover cars, robots, a ship, a basement room full of drawings, an arch in a green fog. Each is a few good textured pieces with depth, haze and one dominant hue.
6. **Texture and flatness**: texture 1.6–2.1 (Laplacian at 1080p) and 14–19 % flat blocks in every video; ours was 1.3 and 32–37 %.

## 12. Look-dev round (2026-11-20): the hero, the room and the numbers
Frame-by-frame work against *Twin Brother* and *The Watcher's Knot* (4K crops side by side, `tools/ref_look.py`). What made the hero and the room read as his:
- **Head:** an egg, not a ball: `spec.headScale = { 1.2, 1.3 }` (wider and taller than the stock R6 head; the mesh and the hair/hat/face attachments scale together). The stock head is smaller than his relative to the body.
- **Face:** small vertical-oval dot eyes, short brows, a small mouth, on the **lower half** of the head (eyes at 58 % of the height). `make_faces_gneef.py` (72 names, `_t` talking mouths). Our earlier faces were large, heavy and centred.
- **Hair:** large and chunky, falling over the forehead, flat orange with a gradient from the key light: `hair_floof` tinted `#F28A2E`, `spec.hairScale = 1.3`. The wispy `hair_messy_anime` looked like strands.
- **Clothes:** cream cable-knit sweater with ribbed neck, hem and cuffs, baggy brown trousers (`make_hero_clothes.py`; `fabricize.py` adds a cable pattern when the name contains "hero"). Keep the dye mottling low (0.02) or the cream turns grey-beige.
- **Room (`lib16_rooms.lua`):** cream smooth walls with soft stripes above a wood wainscot, plank floor, window with curtains, bed, nightstand lamp, rug, shelf, posters, clock, door; **fabric-material walls made the texture metric 2× too high (3.2 vs 1.6)**, smooth walls too flat (flat share 0.36 vs 0.17): stripes and wall objects fixed it. The room is closed (a front wall behind the camera keeps the sun out) and `MT.interiorGrade()` sets a low warm ambient, no haze, `keyB 2.2 / rimB 1.4` portrait lights and `dofFar 0.9`.
- **Readable props:** `MT.noteProp` (paper, dark text). Keep them short (two lines of two words); a long line is cropped by the 9:16 band.
- **Numbers (median of the look-dev frames vs *Twin Brother*):** luma 0.60 / 0.57, contrast 0.25 / 0.22, saturation 0.61 / 0.58, saturation > 0.8 share 0.27 / 0.29, warm bias +0.35 / +0.30, hue entropy 1.01 / 1.00. Still off: dark pixels 7 % / 1.4 %, texture and flat share (depends on the wall treatment).
- **Process traps:** a bed placed over the spot of a prop hid it (check the storyboard for every prop); the preview `top` camera was above the ceiling (use a corner camera in a closed room); `lightOn = "hero"` on a shot lights a character the camera is not built on with `camOn`; capture needs the Studio window in front and the mouse off the 3D view, `preflight.py` now retries parking the mouse six times.

## 13. Round 3 (ep07-knock, 2026-11-20): fixes that stayed, final numbers, what is still open
Fixes now in the kit (each came from a rendered frame, not a guess):
- **Faces above the caption.** The caption band (about 68 % of the height) sat on the eyes of every close-up. `MT.camOn` now aims `MT.CAM_FACE_UP` (0.55 studs) below the face, so eyes and mouth are in the upper half and a word lands on the chin or the sweater. Poppins ExtraBold stays.
- **Room brightness.** The first room render read +0.70 luma against 0.57 and +0.40 warm against +0.30 (cream turned yellow). `MT.INT` (lib16): `exp −0.22`, ambient `(104, 92, 84)`, lamp `1.15`, tint `(255, 246, 238)`.
- **Lived-in detail.** `MT.clutterV2` (toy blocks, ball, slippers, book stack, plant, wall frames, a picture on the nightstand) runs inside `MT.roomV2` (`clutter = false` turns it off). It only shows in wide shots; close-ups need something in the background (frames, shelves) instead.
- **Lights on a wide shot.** `def.lightOn = "hero"` gives the portrait key/rim to a character the camera is not built on with `camOn`.
- **Voice.** `tts_edge.py` defaults are now `en-US-AndrewNeural`, `+45 %`, `+25Hz` (`audio.md` §1.1c); ep07: 257 wpm over the speech, 4.78 s file, cuts re-timed from `words.json`.
- **Gate.** The permission system blocks `build_episode.py --skip-gates` on purpose. After any change to the set or the storyboard: `stage.py revoke set`, recapture, show, ask, approve, render.

Final numbers of ep07 against *Twin Brother* (median of 15 frames): luma 0.64 / 0.57, contrast 0.24 / 0.21, saturation 0.67 / 0.58, share above 0.8 0.37 / 0.29, texture 1.66 / 1.60, flat 0.25 / 0.17, warm +0.41 / +0.30, hue entropy 1.18 / 1.00.

Still open (seen in the render): still 7 points too bright and too saturated; the face in s03 reads grey-pale next to the orange hair; the eyes show a doubled mark in a frame of s05 and s06 while the head moves (a stitch or blend artefact with the roll and `--blur`, to check with `join.py --blur 0`); small props never reach a close-up; far texture is still below his; no outline pass exists in his videos (checked), so do not add one.
