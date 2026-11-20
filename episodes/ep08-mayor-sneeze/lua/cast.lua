-- ep08-mayor-sneeze CAST: the recurring hero (same as ep07), the mayor, five kids in the square
local MT = shared.MT
MT.HD_FACE = false
MT.CASTV.hero = { shirt = "shirt_hero", pants = "pants_hero", hair = "hair_floof", hairColor = "#F28A2E", face = "worried", skin = "#F6D3A8", headScale = { 1.2, 1.3 }, hairScale = 1.3 }
MT.castPreview({ "hero", "kid1", "kid2", "kid3" }, { hero = { "worried", "scared", "shocked" } })
return "cast"
