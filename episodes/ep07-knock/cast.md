# cast.md: stage 1 of the build (copy into the episode folder; `stage.py init` does it)

One row per character who appears in the script, **before any set or shot exists**. The narrator is a character. Fill it from the script and the voice, build each one in Studio (real R6 avatar, outfit, hair, faces: `studio.md` §3), render the cast sheet, show it to the user, then `python stage.py --ep <episode> approve cast`.

| name | role in the story | age / build | outfit (shirt, pants, colours) | hair (MTLib name) | skin | face set (≥ 6 faces they need) | signature prop | voice | lines / share of words |
|---|---|---|---|---|---|---|---|---|---|
| hero (narrator, the recurring hero) | the kid who answered the knock | about 12 | cream cable-knit sweater (`shirt_hero`), baggy brown trousers (`pants_hero`) | `hair_floof`, orange, scale 1.3 | warm peach | worried, scared, shocked (minimal faces, `make_faces_gneef.py`) | none | Windows voice (Zira, pitched up), 238 wpm | all narration |

## Rules for the cast
- **Read at a glance:** every character has a different silhouette and a main colour that reads at thumbnail size (hair + shirt). No two characters share a shirt colour.
- **Hair never covers the eyes** (bold custom faces need the eyes visible); check every face on the sheet.
- **Real avatars:** R6, real shirts and pants, real hair accessories (`studio.md` §3.0–3.1). No classic or noob avatars.
- **Planted object:** the one prop the story pays off later (`roblox-town-script` §2b) is in the cast row of whoever carries it.
- **Faces:** list the face names each character needs from the script (fear, joy, shock, ...); `lua/faces.lua` maps them. A new face is allowed on almost every shot, but every named face must exist before the storyboard.
- Crowd members are not rows: say how many and which kid models (`MT.kid(i)`).

## The cast sheet (the thing the user approves)
`stage/cast_sheet.jpg`: every named character, front and 3/4 view on a neutral set, plus their 3 key faces and the planted object. Make the captures with `checks.ps1` or `rb.py cap`, tile them with `python stage.py sheet stage/cast_*.jpg -o stage/cast_sheet.jpg`.

Approval: date and note are stored in `stages.json`. Changing a character after approval (outfit, hair, face set) means `revoke cast`, which also revokes the set and storyboard approvals.
