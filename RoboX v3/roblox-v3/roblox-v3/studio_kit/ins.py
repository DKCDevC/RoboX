"""Insert free Creator Store accessories into ServerStorage.MTLib (the hair library the cast uses).

  python ins.py hair_floof hair_black_messy          names from hair_ids.json (the six free hairs that fit the R6 head)
  python ins.py name:assetId ...                     any other accessory
  python ins.py --missing                            ask Studio which hairs the episode's cast needs (MT.CASTV, MT.KID_HAIR) that
                                                     MTLib does not have yet, and insert them (stage 1, CAST: a new place has an empty MTLib)

Make sure ServerStorage.MTLib exists first: on E03 (2026-11-20) the hairs were inserted before it existed and landed in Workspace,
where they showed up in every shot."""
import json, os, sys
import rb

HERE = os.path.dirname(os.path.abspath(__file__))
IDS = json.load(open(os.path.join(HERE, "hair_ids.json"), encoding="utf-8"))


def ensure_lib():
    rb.text(rb.lua('if not game.ServerStorage:FindFirstChild("MTLib") then local f = Instance.new("Folder"); '
                   'f.Name = "MTLib"; f.Parent = game.ServerStorage end return "ok"'))


def missing_hairs():
    """Hair names the loaded episode needs and MTLib lacks."""
    code = '''local MT = shared.MT
local need, seen = {}, {}
local lib = game.ServerStorage:FindFirstChild("MTLib")
local function add(h) if h and not seen[h] then seen[h] = true; if not (lib and lib:FindFirstChild(h)) then table.insert(need, h) end end end
for _, spec in pairs(MT.CASTV or {}) do add(spec.hair) end
for _, h in ipairs(MT.KID_HAIR or {}) do add(h) end
return table.concat(need, ",")'''
    r = rb.text(rb.lua(code)).strip()
    return [x for x in r.split(",") if x]


def insert(name, aid):
    r = rb.send({"name": "insert_asset", "arguments": {"assetId": aid, "assetName": name, "assetType": "Model",
                                                      "parentPath": "game.ServerStorage.MTLib", "studio_id": rb.sid}})
    print(name, aid, rb.text(r)[:160].replace("\n", " "))


def ensure_cast_hairs(cast_only=True):
    """Used by stage_capture.py: insert the hairs the cast needs. Returns the names that could not be inserted."""
    ensure_lib()
    todo = missing_hairs()
    bad = []
    for h in todo:
        if h in IDS: insert(h, IDS[h])
        else:
            print("no asset id for", h, "(add it to hair_ids.json or insert it by hand)"); bad.append(h)
    return bad


if __name__ == "__main__":
    rb.sid = rb.studio_id()
    args = sys.argv[1:]
    if args == ["--missing"]:
        bad = ensure_cast_hairs()
        sys.exit(1 if bad else 0)
    ensure_lib()
    for pair in args:
        if ":" in pair: name, aid = pair.split(":", 1)
        else: name, aid = pair, IDS.get(pair) or sys.exit(f"{pair}: not in hair_ids.json, give name:assetId")
        insert(name, aid)
