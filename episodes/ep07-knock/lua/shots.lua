-- ep07-knock STORYBOARD: 6 shots, 5.0 s. Warm room, the recurring hero, a readable note, push-ins everywhere, Dutch roll on the last two.
local MT = shared.MT
MT.resetShots()
local house = MT.house

-- s01 0.00-0.63 "In this house,"  wide, hero small near the bed
MT.shot("s01", { lightOn = "hero", build = function() house(); MT.cast("hero", { 0.6, -1 }, 8, "worried"); return { { 0, -9, 3.6 }, { 0, 3, 4.2 }, 42, push = 0.7 } end, act = function() end })
-- s02 0.63-1.63 "the walls knock back."  the little door in the wall, glowing at the gap
MT.shot("s02", { build = function() house(); return { { -2.4, 1.8, 1.5 }, { -2.4, 8.4, 1.0 }, 34, push = 0.8 } end, act = function() end })
-- s03 1.63-2.20 "Last night,"  hero in profile, listening
MT.shot("s03", { build = function() house(); MT.cast("hero", { -1.2, 3.5 }, 90, "worried"); return { { 3.4, 3.2, 4.2 }, { -1.2, 3.5, 4.3 }, 34, push = 0.8 } end, act = function() end })
-- s04 2.20-3.13 "they knocked my name."  a note against the wall under the door, readable
MT.shot("s04", { build = function() house(); MT.noteProp("note", { "KNOCK", "TWICE" }, { -2.4, 7.9, 1.7 }, 2.0, 1.4, { 0, 0, 0 }); return { { -2.4, 2.6, 2.0 }, { -2.4, 8, 1.6 }, 32, push = 0.7 } end, act = function() end })
-- s05 3.13-4.27 "Mom says never answer."  hero close, a Dutch roll
MT.shot("s05", { roll = function(f) return MT.rollRamp(f, 1, 34, 0, 5) end,
	build = function() house(); MT.cast("hero", { 0, 0 }, 0, "scared"); return MT.camOn("hero", 3.2, 4.8, 5.0, 0.6, 30, 0.8) end, act = function() end })
-- s06 4.27-5.00 "I answered."  bigger face, shocked, a soft punch
MT.shot("s06", { shake = function(f) return MT.punch(f, 1, 0.5, 9) end, roll = function(f) return MT.rollRamp(f, 1, 22, 0, -6) end,
	build = function() house(); MT.cast("hero", { 0, 0 }, 0, "shocked"); return MT.camOn("hero", 3.6, 4.9, 4.9, 0.3, 28, 0.3) end, act = function() end })
return "shots"
