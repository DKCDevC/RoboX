# sets.md: stage 2 of the build (copy into the episode folder; `stage.py init` does it)

One row per location, built and lit **after the cast is approved and before any shot is planned**. Budget: at most 6 sets, at most 2 new (`pipeline.md` build budget); the rest are redressed from earlier episodes (3 props + wall colours). Build each with `MT.streetKit` / `MT.roomKit` / free models unified with `MT.unifyModel`, run the matching lighting family, render the set sheet, show it to the user, then `python stage.py --ep <episode> approve set`.

| set (same spelling in the shot list) | where in the story (% of runtime) | look family | dominant hue | time of day / light | rule object & signs in it | cast who appear | new or reused |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

## Rules for the sets
- **One dominant hue per location** (`look-reference.md` §2): amber/teal desert, purple-orange dusk, warm interior against a deep-blue night. Fill the `dominant hue` column before building.
- **Colour script:** write the story's palette in one line, and mark the story turn where the **whole palette changes** (a ghost world graded cyan-green, a monster night in deep blue). Day and interior scenes warm (R − B +0.09 to +0.27), cool only at night. No vignette.
- **Show the rule:** the rule object or its sign is in the set and readable (`look.md`); big in-world signs carry the facts, text in the top third of the frame.
- **Camera room:** each set must work for a low close shot, a top-down and a wide. Low close shots over rough ground (asphalt, grass) get `MT.calmGround()` or a smooth ground.
- **Physics and clipping:** nothing passes through anything (`studio.md` §4); run the clip scan on the empty set.
- Crowds spaced ≥ 4.4 studs; sets are 1 stud-accurate so characters stand on the floor.

## The set sheets (what the user approves)
`stage/set_<name>.jpg` per location: a wide, a low close angle and a top-down, lit, with the cast who appear standing in it. Tile with `python stage.py sheet stage/set_*.jpg -o stage/set_sheet.jpg`.
Changing a set after approval means `revoke set`, which also revokes the storyboard approval.
