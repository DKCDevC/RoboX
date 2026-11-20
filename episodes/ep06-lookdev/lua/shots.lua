local MT = shared.MT
MT.resetShots()
local function room() MT.family("mid-warm-vivid"); MT.roomV2({}) end
-- l01: medium, the hero holding a note in the room
MT.shot("l01", { build = function() room(); MT.cast("hero", { 0, -1.5 }, 0, "angry"); MT.noteProp("note", { "MY NAME IS THEO.", "I'M YOUR BROTHER.", "MOM IS LYING." }, { 0.5, -2.35, 2.9 }, 2.7, 1.9, { 0, 0, -8 })
	return MT.camOn("hero", 5.2, 3.4, 3.6, 0.4, 32, 0.5) end, act = function() end })
-- l02: close-up face
MT.shot("l02", { build = function() room(); MT.cast("hero", { 0, 0 }, 0, "sad"); return MT.camOn("hero", 3.2, 4.9, 5.1, 0.3, 30, 0.6) end, act = function() end })
-- l03: profile near the bed
MT.shot("l03", { build = function() room(); MT.cast("hero", { -1.5, 3 }, 90, "worried"); return { { 4, 2.8, 3.8 }, { -1.5, 3, 4 }, 34, push = 0.5 } end, act = function() end })
-- l04: low wide of the room
MT.shot("l04", { build = function() room(); MT.cast("hero", { 1.5, 1.5 }, 180, "neutral"); MT.cast("mom", { -3, 3 }, 150, "worried"); return { { 0, -8.5, 1.8 }, { 0, 2, 4 }, 40, push = 0.6 } end, act = function() end })
-- l05: two characters
MT.shot("l05", { build = function() room(); MT.cast("hero", { 0.8, 0 }, 200, "shocked"); MT.cast("mom", { -1.6, 0.8 }, 160, "worried"); return { { 0, 6.5, 4.4 }, { -0.3, 0, 4.4 }, 34, push = 0.6 } end, act = function() end })
-- l06: wide
MT.shot("l06", { build = function() room(); MT.cast("hero", { 2, -1 }, 160, "smile"); return { { 0, -9, 4.2 }, { 0, 4, 4.2 }, 44, push = 0.5 } end, act = function() end })
return "shots"
