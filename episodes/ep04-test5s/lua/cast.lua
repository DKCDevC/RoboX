-- ep04-test5s CAST (stage 1): two characters, reused from ep03 (same outfits, hair and faces).
local MT = shared.MT
MT.HD_FACE = false   -- decal faces, as in E01 / E03

MT.CASTV.me = { shirt = "shirt_c8", pants = "pants_me", hair = "hair_floof", face = "smile" }       -- the narrator
MT.CASTV.brad = { shirt = "shirt_c2", pants = "pants_p2", hair = "hair_black_messy", face = "smirk" } -- the bully

MT.castPreview({ "me", "brad" }, { me = { "smile", "scared" }, brad = { "smirk", "terrified" } })
return "cast loaded"
