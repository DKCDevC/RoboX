import json, sys, rb
rb.sid = rb.studio_id()
# ins.py name:assetId ...
# Make sure ServerStorage.MTLib exists first: on E03 (2026-11-20) the hairs were inserted before it existed and landed
# in Workspace, where they showed up in every shot.
rb.text(rb.lua('if not game.ServerStorage:FindFirstChild("MTLib") then local f = Instance.new("Folder"); '
               'f.Name = "MTLib"; f.Parent = game.ServerStorage end return "ok"'))
for pair in sys.argv[1:]:
    name, aid = pair.split(":")
    r = rb.send({"name": "insert_asset", "arguments": {"assetId": aid, "assetName": name, "assetType": "Model", "parentPath": "game.ServerStorage.MTLib", "studio_id": rb.sid}})
    print(name, aid, rb.text(r)[:160].replace("\n", " "))
