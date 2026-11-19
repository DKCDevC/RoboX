# Set dressing wanted for E01 (from the E01 review: "sets read empty", the biggest drag on the look)

The sets already call `MT.putIf(name, …)` for these names, so nothing breaks while they are missing. When Studio is open:

1. `python search.py "<query>"` for each row, pick a free model with **no scripts**, a sensible size, cartoon/Roblox style, nothing gory or branded.
2. `python ins.py <name>:<assetId> …` (the name must match the first column), then `MT.cleanLib()`.
3. `python load.py --ep <this folder>`, a check sheet (`render.py --tiles 1 --n 1 --force`), fix clipping or blocked views, then render.
4. After a build, `return shared.MT.missingList()` lists any name still missing.
5. Save the place as a `.rbxl` so the library survives the next Studio restart.

| name | search query | used in | placed at (shot coords) |
|---|---|---|---|
| car | "cartoon car" / "low poly car" | street (s01-s12, s29, s30, s33) | parked on the road, x ±24 |
| bench | "park bench" | street | sidewalk, x -15 |
| bush | "bush" / "low poly bush" | street, porch | behind the far sidewalk; in front of the porch deck |
| fence | "white picket fence" | street, porch | street ends; porch yard sides |
| kitchen_cabinets | "kitchen cabinets" / "kitchen counter set" | kitchen (s05, s06) | upper wall cabinets over the counter |
| kitchen_table | "dining table chairs" | kitchen | front left |
| plant_pot | "house plant" / "potted plant" | kitchen, classroom | corners |
| bookshelf | "bookshelf books" | classroom (s07, s23-s27, s32) | back wall, right |
| rocking_chair | "rocking chair" | porch (s13, s15-s19, s31, s34-s40) | deck, left of the door |

Already in MTLib from E01 (studio.md §3.0): hair_black_messy, hair_brown_girl, hair_black_short, hair_floof, hair_pigtails, hair_messy_anime, house_ca, house_cute, tree_cartoon, tree_lp, townhall. The E01 place was never saved, so all of them have to be inserted again in a new place.
