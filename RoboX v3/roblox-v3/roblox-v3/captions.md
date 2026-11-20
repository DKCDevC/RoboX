# captions.md: word-by-word captions at 1080x1920

**One spec.** This is the caption look for every new episode (v3.1, 2026-11-20, measured on the @Gneef Shorts, `gneef-study.md` §5). The earlier looks (E01–E03: 1–2 words, lowercase, red key word; the 6-reel Montserrat spec; the accent-colour rules) are in `legacy/captions-older-looks.md` and are used only when the user asks for one.

## 1. Spec (1080x1920, 30 fps)
| item | value | tag |
|---|---|---|
| Chunking | **one word per caption**, switching on every spoken word (about every 4–8 frames) | REF-RANGE (Gneef; 4 of 6 older refs also) |
| Case | normal capitalisation: "I", names, times ("3:00am"), "Mr", "Sunday" keep their case; other words lowercase | REF-RANGE (Gneef) |
| Fill | white `#FFFFFF`; **no coloured key word** | REF-RANGE (Gneef) |
| Font | **Poppins ExtraBold** (the user's choice, 2026-11-19; free, OFL; `assets/fonts/`) | user choice |
| Size | font about **84 px** (ascender about 60 px) | REF-RANGE (Gneef, estimated from a 4K frame) |
| Position | horizontal centre 50 %; **vertical centre about 68 % of the height (y ≈ 1306)**, never moved per caption. If a word keeps covering the eyes in face close-ups, use y 1400 for the whole episode (E01 found 65 % sat on the eyes) | REF-RANGE (Gneef 68 %) / E01 fix |
| Edge | black outline **about 4 px** plus a soft shadow. The outline carries it on white signs and bright frames | outline width HYPOTHESIS (Gneef's looks thick; E01 shipped 3 px) |
| Punctuation | captions drop commas, full stops and quote marks; keep `?`, `!` and apostrophes (`make_caps.py` does this) | HYPOTHESIS |
| Max width | 65 % of the frame; long words shrink to fit, up to 80 % | REF-RANGE |
| Pop | optional; not measured on Gneef. If used: 125 % to 100 % over 4 frames, no fade-out | REF-RANGE (older refs) |
| Onset | -2 to 0 frames vs the word start (default -1 frame = -33 ms). Target: ≥ 75 % of captions within ±100 ms of the word | REF-RANGE (older refs) |
| Gap between captions | ≤ 1 frame in ≥ 85 % of cases (no blank between words) | REF-RANGE |
| Duration | typical 0.2–0.3 s, minimum 0.1 s; a word is held until the next one starts; in a pause the last caption stays | REF-RANGE |
| Watermark | none by default. Never the Roblox logo or a classic avatar. Optional channel handle top-left, static | REF-RANGE n=1 |

**Keep faces clear of the caption:** the caption sits at about 68 % of the height, so frame close-ups with the face in the upper half (`MT.camOn` aims 0.55 studs below the face by default, `MT.CAM_FACE_UP`); a face that fills the frame still gets a word on its chin, never on its eyes. The font stays **Poppins ExtraBold**.
Make it with: `python tools/make_caps.py <ep>/words.json <ep>/caps.ass` (the defaults are this spec: y 1306, 84 px, outline 4, normal case, no key word, one word each), copy `assets/fonts/Poppins-ExtraBold.ttf` into `<episode>/fonts/`, then `join.py --caps caps.ass` burns it in (libass finds it by the name "Poppins ExtraBold"). `build_episode.py` runs this for you.

### 1.1 Safe zones (HYPOTHESIS: platform conventions, not measured here)
Reels, Shorts and TikTok overlay a caption/handle block and an action-button column. Keep all text inside **x 60–900 and y 250–1550**. A caption centred at y 1306 with 65 % max width clears the bottom block (about y > 1536) and the right button column (x > 960). Check once per platform on a real upload.

## 2. Quality checks
| check | pass |
|---|---|
| captions per spoken word | one each (no 2-word entries) |
| caption centre y | 67–69 % of the height (or 72.9 % if the eyes rule applied) |
| gap ≤ 1 frame | ≥ 85 % of captions |
| onset within ±100 ms of the word | ≥ 75 % |
| first caption | on the first word (0.00–0.20 s) |
| capitalisation | "I", names, times keep their case |
| no red or coloured word | none |
| caption-free picture | colour tests run on `out/picture.mp4`, never on the captioned file (white captions clip at 255) |

## 3. Generating captions automatically (zero tokens, locally)
Pipeline: final voice → word-timestamp JSON → caption events (ASS) → ffmpeg/libass burn-in.
1. **Word timestamps.** `tts_edge.py` and `tts_sapi.ps1` write them with the voice. For a recorded voice: force-align the known script (WhisperX, `stable-ts`) or `faster-whisper` with `word_timestamps=True`; Parakeet timestamps sit on an 80 ms grid, so calibrate with `--lead` and check by eye. No paid transcription without asking.
2. **Run** `python tools/make_caps.py words.json caps.ass` (defaults = this spec; `--lowercase --pair --accent/--sheet` and the old numbers give the older look).
3. **Burn in** with `join.py --caps caps.ass` (or `ffmpeg -i video.mp4 -vf "ass=caps.ass:fontsdir=fonts" -c:a copy out.mp4`).
4. Spot-check 1–2 words per video against the waveform; adjust `--lead` once.

Notes: ASS colours are BGR. `\an5\pos(540,1306)` centres the word, so a pop scales around it. Font, position and outline are fixed across episodes (channel identity); the rotation log needs no caption row.
