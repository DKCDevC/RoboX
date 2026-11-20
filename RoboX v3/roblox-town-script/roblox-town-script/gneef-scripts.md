# gneef-scripts.md: how the @Gneef scripts are written (10 stories, measured 2026-11-20)

Ten Shorts transcribed with whisper (`small.en`, word times) and analysed with `script_stats` style counts: 522–718 words, 114–178 s, 242–276 wpm. This is structure and statistics, not lines: copy the method, never a line shape or a story (`script.md` §9.4). Visual and timing numbers are in the `roblox-v3` skill (`gneef-study.md`). The stats below use the transcripts' own punctuation, which whisper sometimes drops in fast runs, so mean sentence length is a little noisy (the medians are steadier).

## 1. The language fingerprint (check it with `script_check.py`, section 14)
| measure | ten stories | for our scripts |
|---|---|---|
| reading level (Flesch-Kincaid grade) | **2.0–4.9**, mean 3.7 | ≤ 5.5 |
| one-syllable words | **71–79 %** | ≥ 68 % |
| average word length | 3.8–4.2 letters | 3.7–4.4 |
| sentence length, mean / median | 7.0–12.4 / **5–9** (typical median 8) | mean 8–12.5, median 5–9 |
| sentences ≤ 6 words / ≤ 3 words | 31–57 % / 7–28 % | 30–55 % / 8–25 % |
| sentences over 20 words | 1–8 per story (mostly run-ons in a fast read) | still ≤ 20: our rule |
| sentences starting with "I" | 3–18 % | ≤ 20 % |
| starting with And / But / So / Then | 9–23 % | ≤ 25 % (never 3 in a row) |
| starting with "The" | 4–18 % | no target |
| questions / exclamations | 0–4 % / 0–6 % | ≤ 5 % / ≤ 8 % |
| first-person words (I, my, me) | 3–9 % of all words | 3–10 % |
| numbers per 100 s of speech | 4–21 (median 9) | ≥ 4 |
| time markers per 100 s | 2.5–12 (median 5) | ≥ 2.5 |
| first sentence | 8–20 words, "In this …" in 10 of 10 | 8–20 words |
| repeated line (the same 4 words 2–4 times) | **in every story** | at least one |
So the voice is a child's English: short common words, plain verbs, almost no questions or shouting, a few long run-on sentences where the action speeds up. Excitement comes from content and pace, not from punctuation.

## 2. The structure fingerprint (percent of runtime)
| beat | where | note |
|---|---|---|
| rule | 0–5 % | "In this …" sentence one; "You see," opens sentence two (10 of 10); 2–4 sentences of mechanics with a number or a size |
| teaser (optional) | 5 % | a flash-forward from the ending told in one short sentence, answered at about 50 % |
| narrator + anchors | 9–36 % | age or job as a flat fact; a parent and a best friend or sibling, each with one trait or object (the name can come late) |
| inciting event | 17–27 % | a time marker and the first escalation |
| middle | 27–48 % | steps raise the stakes with a sensory detail and a new place; a counter or ritual (a log, tally marks, one note a night); the rule is used, not only stated |
| first reveal | 47–52 % (36 % at the earliest) | the rule's real nature or who is behind it |
| second turn | 78–89 % | the narrator is the cost, the target, or the one who must choose |
| ending | 93–100 % | a callback to a line planted early, or a last line that flips the first one; never a moral |
A story spends about 55–60 % of its words before the first reveal and about 10–15 % after the second turn: the ending is short.

## 3. Ten beat sheets (premises and beats, paraphrased)
| story | rule | narrator and anchors | inciting | first reveal | second turn and ending | twist family (our list) | planted line or object |
|---|---|---|---|---|---|---|---|
| Magic 8-Ball | a giant ball decides everything for the town | 17, writes down other people's questions; mom, a brother who "is not there" | the baker's question, the other bakery vanishes (21 %) | the answers are made true by erasing people (29–36 %) | the narrator starts flickering; wakes the erased sleepers; ends with the ball black (97 %) | the rule was a lie + cost lands on the narrator | the notebook; the snoring through the wall |
| The Worm | a worm eats the fattest person each year | 17, reads the town scale; friend Gus | Gus tops the scale (27 %) | the narrator ate Gus's sweets (52 %) | the worm turns onto the narrator's street; ends on the friend's face at the window (100 %) | cost lands on the narrator | the scale numbers read aloud; "I never read mine" |
| One Child Only | a second baby is taken by a lake creature | the only child; mom, friend Ezra | Ezra's mom has a second baby (39 %) | the twin brother under the lake (60 %) | the narrator takes the twin's place; the mother's lullaby line ends the story (97 %) | mirror / role flip | the lullaby line, said twice |
| Fishing | fish go fishing for people; dangling = hook | kid with a little sister | the sister grabs the bait (24 %) | the fish city's size law (48–59 %) | crouch to look small and the whole bowl escapes, but the narrator is caught; mounted on a wall; the rule repeated by the sister (98 %) | loophole + role flip | the rule sentence, said first and last |
| The Bounty Hunter | an unbeatable hunter is after me | racer, grease pencil behind the ear | the narrator saw something (20 %) | the card says "unharmed" (48 %) | rewrites the card's client name; the hunter protects them; waits at the finish line (99 %) | rule misread / loophole, warm ending | the grease pencil |
| City of Halo | the rich live in a floating city; one lucky kid goes up | 12, weighs the junk that falls; mom | a ring piece with tally marks lands on the scale (49 %) | winners run in rings that hold the city up (81–89 %) | an empty ring with the narrator's name (94 %) | the rule was a lie + cost lands on the narrator | the ring piece, the tally marks, "up is for the worthy" |
| Unmasked | adults never take off their masks | the only kid; dad | dad's mask falls off (teased at 5 %, shown at 50 %) | every adult is me (61 %) | chooses to go back for the new baby (95 %) | mirror | the freckle; "no mirrors" |
| The Red Circle | a red line; outside, a year passes per day | kid; mom, friend Kai | Kai's mother is seen outside (26 %) | color is spreading on Kai (47 %) | Kai gives his red to seal the gap (81 %); the narrator walks the line, Kai waves (98 %) | hidden sacrifice (by the friend) | mom's collar line, said first and last |
| The Watcher's Knot | one person wakes a year to keep watch | kid; mom in the next chest | the narrator wakes (17 %); a counter: nine, fourteen, twenty days | the ship turns around when the sleeper walks (37–48 %) | mom unties the knot in her sleep (78 %); they steer together; land (93 %) | narrator was the cause (sleepwalking) | the knot only two people know, paid off twice |
| Twin Brother | a twin lives inside the walls; three rules | 11; mom | notes slide under the wall (21 %) | the second bracelet in mom's closet (52 %) | the twin takes the narrator's place; the last line doubts which was first (96 %) | role flip / mirror | the three rules; knocks once and twice |

## 4. Devices to use (each is in at least 5 of 10)
1. **A number or a size in the first 10 seconds** that makes the rule impossible to ignore (300 feet, 300 years, 23 masks, a hundred years of sleep).
2. **"You see,"** as the hinge between the rule and its mechanics.
3. **Anchors with a trait or an object** (a parent, a friend or sibling). The stake is who they lose.
4. **A planted line or object that pays off twice** and **a sentence repeated 2–4 times**, often first and last.
5. **A time marker or counter** every 15–25 seconds in the middle.
6. **The rule is used**: a loophole in its wording, or the rule turns on the narrator.
7. **Short flat statements for the biggest facts** ("Nobody who wins ever comes back." as a plain sentence), long run-on sentences when the action speeds up.
8. **One dry joke inside the world-building** (a neighbour living in a fridge who calls it roomy): it makes the dark parts darker.
9. **Concrete sensory detail** at each escalation (wet black fur, rings of teeth, tubes like veins).
10. **The narrator pays** (erased, caught, replaced, or choosing to stay): no story ends with the narrator untouched.

## 5. Devices to avoid (not found in the ten)
Questions to the audience; rhetorical or all-caps emphasis; a moral or a stated lesson in the last lines; a long monologue by a side character; abstract feelings named instead of shown ("I felt guilty").

## 6. Checklist before the user reads the sheet
- Does sentence one hold a number, a size or an odd detail? Does sentence two start with "You see,"?
- Is there a flat statement of age or job and two anchors by the first third?
- Is the inciting event at 17–27 % with a time marker, and is there a counter or ritual in the middle?
- First reveal 47–52 %, second turn 78–89 %, ending ≥ 93 % with a callback?
- Does at least one line repeat 2–4 times? Does a planted object pay off?
- `python tools/script_check.py sheet.md` (section 14) shows the language numbers above; fix every FAIL or say why.
