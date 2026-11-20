-- ep07-knock CAST: the recurring hero (egg head, orange hair, cream cable-knit, brown trousers, minimal faces)
local MT = shared.MT
MT.HD_FACE = false
MT.CASTV.hero = { shirt = "shirt_hero", pants = "pants_hero", hair = "hair_floof", hairColor = "#F28A2E", face = "worried", skin = "#F6D3A8", headScale = { 1.2, 1.3 }, hairScale = 1.3 }
MT.castPreview({ "hero" }, { hero = { "worried", "scared", "shocked" } })
return "cast"
