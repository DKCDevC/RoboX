# gneef-study.md: what the @Gneef Shorts do (measured 2026-11-20)

**Source.** The five newest Shorts of the YouTube channel @Gneef (2.21M subscribers, Roblox "In this town..." stories), uploaded 2026-11-18 to 11-20: *Fishing*, *The Worm*, *One Child Only*, *Magic 8-Ball*, *The Bounty Hunter*. Downloaded in 4K, studied at 30 fps (the two 60 fps files resampled to 30), 576 shots, about 12 minutes of picture. Local copies were for this study only. Tools: `tools/ref_cuts.py`, `tools/ref_motion.py` (the cut detector found 35 cuts on E03, true count 33). Whisper `small.en` for the words.
**Status.** REF-RANGE with n = 5 videos from one channel. It is a second reference beside the six in `look-reference.md`; where they disagree, this file shows what the channel does now, it does not overrule §10. Nothing below has been applied to an episode yet; §8 lists the changes and E03's numbers beside them.

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
- Bold rounded sans, **white**, thick black outline plus soft shadow, about 95 px high at 1080×1920. No coloured key word in these five.
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
- Sentences average 10.6–12.2 words, mixed with 2–4 word punches ("I ran."). Present-tense world, past-tense story. Family or friend stakes (a sibling, a mother, a best friend) in four of five. Three end warm, funny or triumphant, two end dark.

## 8. Gap to E03 and what to change (not applied yet; each needs a render to prove)
1. **Cut faster:** target 7–9 cuts per 10 s, mean shot 1.1–1.4 s, never a shot over 3.5 s. E03 runs 4.8. At 260 wpm that is about 5 words per shot.
2. **Push almost every shot** (≥ 75 %), not 37 %; stills at most 6 %. Add roll (Dutch turn) to about 25–30 % of shots and keep it for tense beats.
3. **Make the characters act in about half of the shots** (E03: 34 %); no pose-and-hold.
4. **Colour per location with a hard change at the turn;** warm bias +0.1 to +0.25 for day and interior scenes, deep blue allowed at night, and **remove the vignette** (E03's grade adds one: corners 0.93 vs 0.96+). Raise mean luma from 83 toward 100–120 in day scenes; keep saturation 0.5–0.7 (E03 is 0.74, already high).
5. **Captions: one word per caption**, 68 % height, white + black outline, normal capitalisation (E03: 1–2 words, lowercase, one red word).
6. **Voice 250–270 wpm** (E03: 186; see `audio.md` §1.2b / §1.1c for 1.2× and above), continuous, no designed pauses. Check against `script.md` §6 (the pause rule) before adopting; that rule is from the six older refs.
7. **No exposure flashes;** use cuts plus shake and push on impacts.
8. Script: keep the E03 formula (rule in sentence 1) and add the age line, two family or friend anchors, one planted object that pays off, a time marker for the inciting event, a twist by 36–60 % and a second turn by 80–90 %, and an ending that calls back a planted line. Mind the rotation log: do not copy a story, only the structure.

## 9. Method notes and limits
- Cut detection: mean absolute difference of 54×96 greyscale frames; a cut is a frame-to-frame jump above 9 grey levels and 4.5× the local median. It misses slow dissolves (none seen) and can double-count a fast whip.
- Motion: Farneback optical flow at 135×240, zoom and roll from a least-squares fit of the flow field. Rates are in fractions of the frame per second; thresholds in `ref_motion.py` calls above are push > 0.025/s, roll > 0.03/s.
- Audio words come from whisper `small.en`; timings are good to about 0.1 s. Loudness from `ffmpeg ebur128` on the original files.
- Five videos from one channel on three days: a recent snapshot, not a rule. Re-run the tools when the channel changes.
