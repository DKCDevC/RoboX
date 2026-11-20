-- ep05-test5s CAST (stage 1)
local MT = shared.MT
MT.HD_FACE = false
MT.CASTV.me = { shirt = "shirt_c8", pants = "pants_me", hair = "hair_floof", face = "smile" }   -- the narrator, recurring hero
MT.castPreview({ "me", "kid1" }, { me = { "smile", "shocked" }, kid1 = { "oh" } })
return "cast loaded"
