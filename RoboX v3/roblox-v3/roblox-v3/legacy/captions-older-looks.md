# captions-older-looks.md (retired 2026-11-20)

The caption looks used before the @Gneef update. Use them only when the user asks for one by name. The current spec is `captions.md`.

## A. E01–E03 look ("v3": 1–2 words, lowercase, red key word)
| item | value | tag |
|---|---|---|
| Chunking | 1–2 words at a time | REF-RANGE (older reels) |
| Case | lowercase; the one key word per sentence in ALL CAPS | REF-RANGE |
| Fill / accent | white; key word red about `#e8452c` | REF-RANGE |
| Font | Poppins ExtraBold | user choice |
| Size | cap height about 50 px, font about 70 px | REF-RANGE (estimate) |
| Position | the refs centre at 65 % (y 1248); E01 used y 1400 (73 %) because at 65 % the words sat on the eyes in close-ups | E01 fix |
| Edge | soft shadow plus a 3 px outline | E01 fix |

How it was made on E01: lowercase every word in `words.json` and write each row's key word in CAPS (the sheet's caption-highlight column); merge neighbouring short words (≤12 letters together, inside one sentence, neither the key word) into one entry; `python tools/make_caps.py words_caps.json caps.ass --accent-at "<key word start times>" --y 1400 --fs 78 --outline 3 --color E8452C --font "Poppins ExtraBold"`; `make_caps.py` prints the accent share per entry (above 13 % after pairing is normal; E01: 12 % of words).

## B. Highlight rule (accent colour)
- One accent colour per video. Default yellow `#FEDD30` (bell) or red `#FD3433` (memories); warm/wonder yellow, horror/violence red (HYPOTHESIS). Rotation logged in the rotation log.
- Hook: the whole first sentence in the accent colour (bell 0.2–3.7 s, memories 0.0–4.07 s; 2 of 6 refs). Optional; alternate on/off.
- After the hook: accent only character names, the rule's words and the 1–2 emotional peak words; at most one accent per sentence; ≤13 % of the words is a ceiling; never function words. `script_check.py` prints the share.
- Train used one fixed lime `#E2FD00` for every word: a valid alternative.
- Machine-readable twin of this look: `templates/caption-preset.json`.
- Accent via the sheet: `--sheet script-sheet.md` lights exactly the word in each row's `caption highlight` cell; `--accent "Chloe,bell"` lights every occurrence; `--accent-at "31.0,97.4"` lights one occurrence by time.

## C. The 6-reel spec (Montserrat 104 px, y 1344, 12 px outline)
One word per caption; Montserrat ExtraBold, 104 px, vertical centre 70.0 % (y 1344), max width 65 %, white, black outline 12 px, shadow y+6, pop 125 % → 100 % over 4 frames; phrase mode (Anton, 1–3 words) only at 245+ wpm. Rotation row 25 of `templates/rotation-log.md` logged accent colour, hook accent and one-word vs phrase mode.
