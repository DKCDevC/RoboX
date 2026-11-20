# reference look: STYLE.md (v3.1, one set of numbers)

Measured from two sets of references:
- **Older reels (A):** 5 Shorts, 34,398 frames, 660 shots: The Last Guardian (4.3M), I got the Weakest Power (2.8M), Forbidden Prison Pt 2 (844K), The Boy Who Was Sold for 100 Gold (172K), He Knew My Name (151K).
- **@Gneef (B), 2026-11-20:** ten Shorts (the newest ten), 1,218 shots, 30 fps, `gneef-study.md` §2–§11. B is the channel the user wants new episodes to match. **Where A and B differ, the numbers below are B's.** A is kept only where B has nothing to say.
All numbers are REF-RANGE unless marked. This file is the single source of numbers for the look; `look.md`, `pacing.md`, `captions.md`, `lighting-color.md` follow it (§10 lists their old numbers it replaced).

## 1. The look in one paragraph
Bright, saturated, **warm** Roblox with real movie-camera habits. Real R6 avatars in real clothes with custom, very expressive faces. One dominant colour per location, blurred backgrounds on close-ups, fog, light shafts, bloom on glow. The camera lives close, **pushes in on almost every shot**, tilts (Dutch) on tense beats and shakes on impacts. Characters act in about half of the shots: running, climbing, flinching, turning. Cuts are fast (7–10 per 10 s). Captions are one white word at a time with a black outline.

## 2. Look families, palette and exposure (use the matching lighting file)
| family | used for | share of time | brightness | contrast | black pt | white pt | saturation | shadow | mid | highlight | shadow warmth | highlight warmth |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mid-neutral-normal | daylight indoors (office, house, school), normal life | 28% | 0.495 | 0.326 | 0.007 | 0.969 | 0.333 | #0b0b17 | #919397 | #f8f3e4 | -12.6 | +20.2 |
| mid-warm-vivid | golden hour, desert, fire-lit, "power" moments | 28% | 0.326 | 0.294 | 0.004 | 0.924 | 0.706 | #0a0303 | #855623 | #f4e58f | +7.5 | +101.7 |
| dark-neutral-vivid | blue dusk / night / dim halls, tension | 27% | 0.298 | 0.264 | 0.003 | 0.888 | 0.581 | #050517 | #515367 | #d9d9d0 | -18.2 | +9.6 |
| bright-warm-vivid | gold palace, kings, rewards, glory | 10% | 0.621 | 0.245 | 0.086 | 0.940 | 0.634 | #672f14 | #d6a956 | #fbf0b9 | +83.0 | +65.8 |
| dark-warm-vivid | lava, hell, villain throne, danger | 5% | 0.096 | 0.115 | 0.003 | 0.495 | 0.694 | #050101 | #3f1010 | #af5742 | +3.3 | +109.8 |
| bright-neutral-normal | heaven light, power reveals | 2% | 0.715 | 0.182 | 0.263 | 0.962 | 0.208 | #59667e | #b6bdc0 | #f3f1e1 | -37.2 | +17.6 |

Palettes: mid-neutral #ebece1 #03040b #9eb4d1 #6b6580 #302952 #e1a64b · mid-warm #140705 #532212 #f7db3c #b93b0a #e4e4b1 #b48b57 · dark-neutral #130c18 #58596f #78aae1 #e9d5ad #09248a #c45b24 · bright-warm #f5e0ae #f8d14c #e09b31 #431707 #9b4a1d #c3a685 · dark-warm #0e0104 #380e10 #6b0f07 #66565e #ca240a #d9bb84 · bright-neutral #eef1f0 #8f837f #bdc5cf #4a4856 #4f9dea #eddd72

Whole videos (B): **mean luma 95–123 of 255 (0.37–0.48), contrast (luma std) 47–65, saturation 0.49–0.70, darkest 1 % at 3–27, brightest 1 % at 193–219, warm bias (R − B)/255 of +0.09 to +0.27.** Day and interior scenes are warm; cool is for night. Deep blacks are fine at night.
**Colour script.** One dominant hue per location (amber/teal desert, purple-orange dusk, warm interiors against deep-blue night streets), and the **whole palette changes at a story turn** (a ghost world graded cyan-green, a monster night in deep blue). Warm light on faces against a cool ambience. **No vignette** (corner ÷ centre brightness 0.96–1.27).

## 3. Camera grammar
- Shot moves (B, 576 shots): **push in on 79 %** (65–89 % per video; about 6 % zoom per second, many bigger punch-ins), pull out 9 %, **still only 6 %**. **Roll (a Dutch tilt that turns 3–8° during the shot, HYPOTHESIS for the angle) on about 37 %** (29 % in batch 1, 44 % in batch 2, 66 % in the busiest video), most on tense beats. Pans rare (8 %). Shake 14–22 %, mostly on impacts. `def.roll` and `MT.rollRamp` in `lib11.lua` (UNTESTED in Studio).
- Angles are extreme and varied: faces filling the frame, straight top-down, worm's-eye, wide lens, objects passing close to the lens. A reveal gets one wide shot, then back in.
- **Depth of field ON for close-ups:** background trees, walls and crowds are soft.
- Big readable in-world signs carry facts ("TOWN RULE #1", "FISHING LAW", "BOUNTY #3007").

## 4. Edit rhythm
- **7–10.5 cuts per 10 s; mean shot 0.95–1.4 s, median 0.9–1.25 s; few shots over 3.5 s (0–4 per video, none over 6 s)**; 26–39 % of shots are under 1 s. Even across the runtime, including the first 3 s and the last 10 s. About 5 words per shot at 260 wpm.
- **No flashes** (none found in B; A's white flashes are dropped). Impacts are a cut plus shake plus push.
- First 3 s: the rule line over a big set, cutting at body pace. Cuts on sentence starts (57–82 % of sentence starts get a cut).

## 5. Characters and faces
- Real R6 Roblox avatars with real clothing; a hero with a distinct hair and outfit.
- Custom faces, not default decals: big white eyes with black pupils, thick angled brows, open mouths with teeth, sweat drops. A new face on almost every shot.
- Fantasy characters: long white anime hair, gold armor, wings, glowing marks, villains in red/black. Crowds fill stadiums and streets.

## 6. Movement (characters don't just stand)
- **Characters act in about half of the shots** (B: 33–67 % per video), animation continuous (run, climb, flinch, turn); never pose-and-hold.
- Classic Roblox R6 walk and run animations with big arm and leg swings, at walking speed (≥ 8 studs/s walk, ≥ 14 run).
- Signature shot: a character runs straight at a low camera until he fills the frame. Characters walk across frame, enter and leave frame, get grabbed or pushed, fall, fly. Feet stay on the ground with hard sun shadows.

## 7. Captions
Summary of `captions.md` (the spec): **one word per caption**, switching on every spoken word; white with a black outline plus soft shadow; no coloured key word; centre about 68 % of the height (y ≈ 1306); font about 84 px; normal capitalisation (I, names, times keep their case).

## 8. Effects
- Bloom/glow on neon, powers, lamps; fire and lava glow; fog and haze in horror; light shafts; dust, snow and spark particles; hard sun shadows by day.
- Screen shake on impacts and runs; Dutch roll on tense beats (§3).
- **No vignette, no exposure flashes, no grain.**

## 9. Never do
- Grey, low-saturation scenes for normal life (our old toon look, not theirs).
- Shots over 3.5 s; still shots over about 6 % of the cuts; pose-and-hold characters.
- Plain block characters or default faces.
- A red or coloured caption word, ALL-CAPS captions, lowercase "I" or names.
- A vignette or an exposure flash.

## 10. What this file replaced (old files, one table, current values)
`look.md`, `lighting-color.md`, `pacing.md`, `captions.md` and `legacy/style-toon.md` were written for earlier looks. Their method, checks and every rule **not** listed here still apply; where they quote a number from this table's left column, use the right column.

| old file, rule | old value | current value |
|---|---|---|
| pacing.md §2 rule 3, look.md L9 | mean shot 1.3–2.5 s, median 1.3–2.0 s, 20–48 cuts/min | **7–10 cuts per 10 s, mean 1.1–1.4 s, median 1.1–1.25 s** (§4) |
| pacing.md §2 rule 4 | 5–6 words per shot | about 5 words per shot at 250–270 wpm (§4) |
| pacing.md §2 rule 6, look.md L9 | no shot over 3.5 s, 1–2 holds of 4–6 s | **few shots over 3.5 s (0–4 per video, none over 6 s)**, no designed holds needed (§4) |
| pacing.md §3 first 10 s | ≥4 cuts, shot 1 up to 3.0 s | cut at body pace from the start (7–10 per 10 s); hook on a big set |
| look.md L7, L8, L20 | ≥70 % real in-engine moves, push-ins ≤40 % | **push in ≥ 75 %**, roll ≈ 28 %, still ≤ 6 %, shake ≈ 14 % (§3) |
| look.md L15, §8 | stiff idle ≤40 %, posed ≥35 %; Motor6D poses, Moon Animator, RoMixamo | **characters act in about half of the shots** (§6); real R6 avatars + Roblox R6 walk/run/idle clips, `studio.md` §3.1 |
| look.md §7 face kit | 19 layered PNGs per character | bold custom faces, a new face on almost every shot (§5); kit `studio_kit/make_faces_v2.py` |
| look.md L19, §9 cast | custom hero rig | real R6-look avatars in real clothes and hair (§5; `studio.md` §3) |
| lighting-color.md §1, §3 | mood presets in `lighting-presets.lua` | 6 look families, files in `assets/lighting/reference/` (§2) |
| lighting-color.md C1, C2 | median sat 0.35–0.50, ≤10 % of shots over 0.60 | **video sat 0.49–0.70**, mean luma 95–123 (§2) |
| lighting-color.md C4 | p1 10–25, little crush | near-pure blacks allowed (p1 3–27), esp. at night (§2) |
| lighting-color.md vignette row | none | **none** (§2) |
| lighting-color.md colour script | mood per scene | one dominant hue per location, hard palette change at the turn (§2) |
| captions.md (old §0, §1, accent rules) | 1–2 words lowercase red key word; or Montserrat 104 px, yellow accent, y 1344 | **one word, white, outline, y 1306, 84 px, normal case, no key word** (§7, `captions.md`); old looks in `legacy/captions-older-looks.md` |
| audio.md §1.2, script.md §6 | 185–240 wpm, 2–3 designed pauses | **250–270 wpm, continuous; at most one or two short pauses (0.4–1.3 s; the usual one, 0.4–0.8 s, sits before the last line)** (`audio.md` §1.2, `script.md` §6) |
| join.py grade | vignette 0.24, saturation +6 % | no vignette, contrast +6 % only |
| loudness | −14 LUFS | unchanged: −14 LUFS, ≤ −1.0 dBTP (B's mix is about −17; the platforms normalise both) |

Still the same in every file: cuts on sentence starts, rule object in shot 1 and ≥50 % of shots, readable signs, the twist-cut colour shift, no-clipping and physics rules, safe zones.
Measured on E03 against these numbers: 4.8 cuts per 10 s, 37 % push-ins, 11 % roll, 31 % still, luma 83, warm −0.05, vignette 0.93, 186 wpm. The first episode built to this file is the proof (`gneef-study.md` §8).

## Status
Lighting files in `lighting-<family>.lua` are STARTING values from these numbers. They still need the Step 7 match test in Roblox Studio (`compare.py` against `_summary/family_<family>.png`). The B numbers (push, roll, cut rate, no flash, no vignette) are measured but not yet proved on a render.
