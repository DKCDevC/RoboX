# Script sheet: In This Town, The Crosswalk Light Turns Red When A Bully Steps Onto It

## Header

| field | value |
|---|---|
| Episode | E03 |
| Rule (line 1, 8-15 words) | In this town, the crosswalk light turns red when a bully steps onto it. |
| Rubric score (/12, tests 1-6) | 1: 2 2: 2 3: 2 4: 2 5: 2 6: 2 = 12/12 |
| Comment-bait question | Would that crosswalk turn green or red if you stepped onto it? |
| Twist family / ending payoff type | 11 (Mirror) / rule-object state + small-action motif |
| Rotation checked (`script_check.py --log`): core fields vs the last 3-5 rows | E01 used family=4, subject=grandparent-narrator, outcome=dread, reveal=64%, event=A, reveal_move=rule-works-otherwise. E03 shifts all 7 core fields (11, self, exposure, reveal ~52%, B, what-i-was). |
| Target runtime (60-180 s) and reveal % (Variant A ~52 % / B ~68 %, >=10 points from last episode) | 67.0 s, reveal ~52 % |
| Motif (3+ uses, last in final 10 %) | silver patrol whistle (rows 7, 32, 37) |
| Planted clues and the joke clue | 1) Narrator shoves Owen behind the stripe as a "safety" joke (rows 12-13); 2) Coach says Oak Street stayed green all fall before March (row 15); 3) Narrator was always in front while Owen was behind (rows 8-9). |
| Cast and voices | NARR = kid narrator (AndrewNeural +0%); BRAD = classmate (-2 st); COACH = Coach Miller (-4 st) |
| Music plan | Cue A calm school-morning bed (0.0-35 s) -> EVENT 1 type B (cue change to tense low pulse on TWIST cut ~35 s) -> soft uneasy outro |
| Words / speech end / runtime / reveal % | (filled after plan_timing.py) |
| Tone | funny-cocky -> uneasy -> exposed |
| Skeleton | family=11; sign=place-or-world; belief=villain-person; reaction=mock; discovery=rule-test; subject=self; outcome=exposure; climax=public-stand; ending=empty-space; lastline=small-action-motif; reveal=what-i-was; signature=none |
| Music event 1 type | B (cue change) |
| Twist mechanism words | it was me, i was the bully, for me, myself |
| Twist clues (2-4; mark <=2 direct) | 1) joke clue: narrator shoves Owen back ("Stay behind the stripe, dude") [direct #1]; 2) Coach says Oak Street stayed green all fall before March [direct #2]; 3) Owen's Elm Street light stays green without narrator [indirect]. |
| Guess test (script.md §3.3) | UNCHECKED (blind reader check pending user read) |
| Logic questions (script.md §3.4) | 1) Why didn't narrator cross alone earlier? His 7:45 shift started right when Owen's bus arrived behind him. 2) Why didn't Owen speak up? Owen stayed quiet and started walking two blocks away on Elm Street. 3) Why didn't Coach notice? Coach only saw the crowd and tracked Friday totals on his clipboard. |
| Staged contrast | none |

## Sheet

| # | time (s) | line | speaker | beat | shot (size + subject) | camera | lighting mood | music cue | SFX | caption highlight |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.1-3.9 (0 %) | In this town, the crosswalk light turns red when a bully steps onto it. | NARR | hook / rule, rule clear | WS: sunny Oak Street crosswalk, patrol kid at curb as beacon snaps bright red | low track forward, moving on frame 1 | mid-neutral-normal | Cue A in at 0.0 (light school pluck) | buzz-snap | red |
| 2 | 3.9-6.1 (6 %) | I guarded Oak Street for that gold vest. | NARR | stake | MCU: narrator in blue patrol shirt pointing proudly to safety sash | slow push-in | mid-neutral-normal | A | - | gold |
| 3 | 6.1-8.0 (9 %) | Last month, Brad stepped off the curb. | NARR | example 1 | MS: tall kid Brad smirking with backpack stepping onto crosswalk stripe | static hold | mid-neutral-normal | A | footsteps | - |
| 4 | 8.0-9.1 (12 %) | The sign flashed red. | NARR | example 1 | CU: giant red crosswalk light glaring on Brad flinching | shake on flash | mid-neutral-normal | A | loud buzz | - |
| 5 | 9.1-10.2 (14 %) | Brad dropped his lunchbox. | NARR | example 1 | INSERT: lunchbox hitting street beside sneaker as kids laugh behind | whip pan | mid-neutral-normal | A | clatter | - |
| 6 | 10.2-11.6 (15 %) | Honestly, I loved that job. | NARR | status quo | MS: narrator guiding small kids across green crosswalk | track sideways | mid-neutral-normal | A | - | - |
| 7 | 11.6-13.2 (17 %) | I polished my whistle every night. | NARR | motif 1/3 | INSERT: narrator polishing shiny silver whistle near blue sash | slow push-in | mid-warm-vivid | A | - | whistle |
| 8 | 13.2-15.1 (20 %) | Then Owen joined my bus in March. | NARR | inciting | MS: shy kid Owen in striped shirt stepping off yellow school bus | pan with Owen | mid-neutral-normal | A | bus door hiss | Owen |
| 9 | 15.1-16.7 (23 %) | Every morning, that light buzzed red. | NARR | flaw | WS: narrator walking ahead, Owen jogging behind, red beacon glowing above | pull-back | mid-neutral-normal | A | buzz | - |
| 10 | 16.7-18.6 (25 %) | "Keep Red Light Owen off our street!" | BRAD | misread | CU: Brad pointing down the sidewalk toward Owen | punch-in | mid-neutral-normal | A | - | - |
| 11 | 18.6-20.0 (28 %) | I kinda laughed along too. | NARR | reaction | MCU: narrator smirking and shrugging with clipboard | slow push-in | mid-neutral-normal | A | - | - |
| 12 | 20.0-21.6 (30 %) | I shoved Owen behind the line. | NARR | clue 1 (joke) | MS: narrator pushing Owen back onto sidewalk edge | handheld slight | mid-neutral-normal | A | - | - |
| 13 | 21.6-23.6 (32 %) | "Stay behind the stripe, dude," I joked. | NARR | clue 1 (joke) | CU: narrator grinning smugly, Owen stepping back looking down | slow push-in | mid-neutral-normal | A | - | - |
| 14 | 23.6-25.5 (35 %) | Same loud buzz at 7:45. | NARR | clue 2 | CU: crosswalk pole red light pulsing behind narrator's shoulder | shake | mid-neutral-normal | A | loud buzz | - |
| 15 | 25.5-27.1 (38 %) | Coach Miller checked his clipboard Thursday. | NARR | clue 3 | MCU: Coach Miller looking down at patrol clipboard | slow push-in | mid-neutral-normal | A | - | - |
| 16 | 27.1-28.7 (41 %) | "Oak Street stayed green before March." | COACH | clue 3 | CU: Coach Miller speaking, brow furrowed, green sign behind him | static hold | mid-neutral-normal | A | - | green |
| 17 | 28.7-30.6 (43 %) | Friday morning, I came at 7:30. | NARR | doubt | WS: empty sunny Oak Street crosswalk, no bus in sight | crane down | mid-neutral-normal | A | - | - |
| 18 | 30.6-31.2 (46 %) | Zero kids. | NARR | doubt | MS: empty bus stop bench and blank sidewalk | pan | mid-neutral-normal | A | - | - |
| 19 | 31.2-32.8 (47 %) | I saw Owen on Elm Street. | NARR | doubt | WS: down the street, Owen crossing Elm Street smoothly | zoom in | mid-neutral-normal | A | - | Elm |
| 20 | 32.8-33.4 (49 %) | Green light. | NARR | doubt | MS: Owen walking safely under glowing green Elm Street beacon | static hold | mid-warm-vivid | A | soft chime | GREEN |
| 21 | 33.4-35.0 (50 %) | I stepped onto Oak Street alone. | NARR | reveal | MS: narrator stepping alone onto Oak Street white stripe, chest out | track beside | mid-neutral-normal | A drops out | footsteps | - |
| 22 | 35.0-37.2 (53 %) | The light blasted red right in my face. | NARR | TWIST | ECU: narrator frozen wide-eyed bathed in sudden neon red glare | dolly-zoom | dark-neutral-vivid | EVENT 1 type B (low tense pulse) | heavy alarm buzz | RED |
| - | 37.2-38.2 | *(pause 1.0 s, hold on narrator frozen under the red glare)* | - | pause A | ECU: hold on red light reflecting on narrator's face | slow push-in | dark-neutral-vivid | pulse holds | - | - |
| 23 | 38.2-38.5 (57 %) | Wait. | NARR | turn | CU: narrator blinking fast in red glow | static hold | dark-neutral-vivid | B | - | - |
| 24 | 38.5-40.6 (58 %) | I stepped one foot back onto the curb. | NARR | turn | INSERT: narrator's sneaker stepping back off white crosswalk stripe | tilt down | mid-neutral-normal | B | - | - |
| 25 | 40.6-41.2 (61 %) | Bright green. | NARR | turn | CU: crosswalk beacon snapping instantly back to bright green | punch-in | mid-neutral-normal | B | chime | GREEN |
| 26 | 41.2-42.8 (62 %) | I stepped onto the paint again. | NARR | turn | MS: narrator stepping forward alone onto crosswalk | slow push-in | dark-warm-vivid | B | - | - |
| 27 | 42.8-43.4 (64 %) | Red again. | NARR | turn | ECU: giant red beacon glowing right over narrator's terrified eyes | shake | dark-warm-vivid | B rises | loud buzz | RED |
| 28 | 43.4-45.3 (65 %) | Twenty kids stared from the bus stop. | NARR | turn | WS: crowd of kids at school bus stop staring silently at narrator | pull-back | dark-neutral-vivid | B | - | - |
| 29 | 45.3-45.8 (68 %) | Nobody moved. | NARR | turn | MS: silent row of kids behind bus stop fence | pan | dark-neutral-vivid | B | - | - |
| 30 | 45.8-46.9 (69 %) | "Look, nobody's behind him." | BRAD | turn | MCU: Brad standing by gate pointing straight at empty street behind narrator | quick push-in | dark-neutral-vivid | B | - | nobody's |
| 31 | 46.9-49.4 (70 %) | I literally stood frozen there for five whole seconds. | NARR | climax | CU: narrator frozen on white stripe while bus line watches | slow push-in | dark-neutral-vivid | B | - | - |
| 32 | 49.4-52.1 (74 %) | Coach Miller walked out and picked up his red pen. | NARR | climax | MCU: Coach Miller looking disappointed, picking up his red pen | static hold | mid-neutral-normal | B | - | - |
| 33 | 52.1-54.8 (78 %) | My silver whistle felt kinda heavy around my neck now. | NARR | turn, motif 2/3 | CU: narrator looking down, grabbing his silver whistle | slow push-in | dark-neutral-vivid | B | - | - |
| 34 | 54.8-57.6 (82 %) | I handed Coach my patrol clipboard by the school gate. | NARR | turn | MS: narrator holding clipboard out to Coach Miller, head down | slow pull-back | mid-neutral-normal | B softens | - | - |
| 35 | 57.6-60.3 (86 %) | Across the street, Owen walked calmly under green crosswalk lights. | NARR | extra payoff | WS: Owen walking peacefully under bright green Elm Street sign | pan | mid-warm-vivid | B | - | - |
| 36 | 60.3-61.9 (90 %) | I walked down Oak Street alone. | NARR | extra payoff | MS: narrator walking away from school gate toward Elm Street | slow push-in | dark-neutral-vivid | B | footsteps | - |
| - | 61.9-62.7 | *(pause 0.8 s, hold as narrator reaches Elm Street alone)* | - | pause B | MS: narrator stopping alone at the Elm Street curb | slow push-in | dark-neutral-vivid | B fades | - | - |
| 37 | 62.7-65.4 (94 %) | I gripped my whistle, and Elm Street buzzed bright red. | NARR | LAST LINE, motif 3/3 | WS: narrator alone on Elm Street, red crosswalk flashing behind him | pull-back | dark-warm-vivid | soft low note tail | buzz | red |

## Titles and covers

### 3 Titles
- Format A: `In This Town, The CROSSWALK Turns RED For Bullies 😳`
- Format B: `In this town, the crosswalk light turns red when a bully steps onto it.`
- Format C: `In This Town, Crosswalks Catch Bullies. Then Mine Turned Red 😭`

### 3 Cover texts
- `WHO SET IT OFF?`
- `NOBODY BEHIND ME`
- `WHY DID IT FLASH RED?`

## Rotation log row

| ep | date | family | subject | outcome | tone | reveal % | event type | reveal move | skeleton | optional | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E03 | 2026-11-20 | 11 | self | exposure | funny-cocky -> uneasy -> exposed | 52 | B | what-i-was | family=11; sign=place-or-world; belief=villain-person; reaction=mock; discovery=rule-test; subject=self; outcome=exposure; climax=public-stand; ending=empty-space; lastline=small-action-motif; reveal=what-i-was; signature=none | misread=narrator-crowd; rule=place; where=on-buildings; lastline=small-action-motif; twist-shift=warm-to-cold | ep03 draft at Gate 1 |
