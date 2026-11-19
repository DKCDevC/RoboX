-- E01 "In this town, you only get 100 words a day": 39 shots (times in shots.json; frame counts come from load.py).
-- Helpers (MT.shot, MT.cast, MT.counter, MT.camOn, MT.family, MT.around, MT.chatter) live in studio_kit/lib11.lua.
local MT = shared.MT
MT.resetShots()
local shot, cast, counter, anim, face, walk = MT.shot, MT.cast, MT.counter, MT.anim, MT.actorFace, MT.walkTo
local around, chatter = MT.around, MT.chatter

---------------------------------------------------------------- rule (0-5.8 s)
shot("s01", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("jay", { -8, 2 }, 90, "neutral")
	cast("kid1", { 6, 4 }, -90, "talk"); cast("kid2", { 2.6, 4.2 }, 90, "smile"); cast("kid3", { 13, 2.5 }, -90)
	cast("kid4", { -16, 4.5 }, 0, "content")
	return { { -1, -9.5, 4.2 }, { -2, 10, 5 }, 24, push = 2 }
end, act = function(f, n)
	walk("jay", f, 1, n, { -8, 2 }, { -3.5, 2 }); walk("kid3", f, 1, n, { 13, 2.5 }, { 9, 2.5 })
	counter("jay", 100); counter("kid1", 63); counter("kid2", 81); counter("kid3", 45); counter("kid4", 92)
	anim("kid1", "point", 1)
end, speak = "kid1" })

shot("s02", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("kid5", { 3, 3.5 }, 10, "smile"); cast("kid2", { -2, 6 }, 60, "talk")
	return MT.camOn("kid5", 5.2, 4.4, 5.1, 0.9, 30, 0.7)
end, act = function(f, n) counter("kid5", 100); counter("kid2", 74) end, speak = "kid2" })

shot("s03", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("jay", { 0, 3.5 }, 0, "smirk")
	return MT.camOn("jay", 4.8, 3.9, 5.1, -0.7, 28, 0.9)
end, act = function(f) counter("jay", 100) end })

shot("s04", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("kid6", { 0, 4 }, 0, "shocked"); cast("kid7", { 3.8, 4.6 }, -100, "oh")
	return MT.camOn("kid6", 8.2, 3.6, 4.4, 2.0, 28, 0.5)
end, act = function(f) counter("kid6", 0); counter("kid7", 58); anim("kid6", "point", 1) end, speak = "kid6" })

---------------------------------------------------------------- me + life under the rule (5.8-19 s)
shot("s05", { build = function()
	MT.setKitchen(); MT.family("mid-warm-vivid")
	cast("mom", { 2.6, 5 }, -55, "angry"); cast("jay", { -2.6, 5 }, 55, "sleepy")
	return { { 0, -6.5, 4.2 }, { 0, 5, 4.6 }, 26, push = 1.2 }
end, act = function(f) anim("mom", "point", 1); counter("mom", 64); counter("jay", 100) end })

shot("s06", { build = function()
	MT.setKitchen(); MT.family("mid-warm-vivid")
	cast("mom", { 2, 5 }, -55, "smile"); cast("jay", { -3, 4 }, 80, "sleepy")
	return MT.camOn("mom", 4.6, 4.4, 4.95, 0.6, 30, 0.6)
end, act = function(f) counter("mom", 64); counter("jay", 100) end, speak = "mom" })

shot("s07", { build = function()
	MT.setClass(); MT.family("mid-neutral-normal")
	local k = 0
	for r = 0, 1 do for c = -1, 1 do k += 1; cast("kid" .. k, { c * 7 + 2, 2 + r * 5 }, 0, k % 2 == 0 and "happy" or "content") end end
	return { { 2, -15, 9.5 }, { 2, 5, 3.2 }, 26, push = 2 }
end, act = function(f)
	for k = 1, 6 do anim("kid" .. k, "wave", 1 - k * 5); counter("kid" .. k, 100 - k * 3) end
end })

shot("s08", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("kid8", { 17, 24 }, -150, "oh")
	return { { 11, 11, 4.4 }, { 12.5, 27, 5 }, 26, push = 2.2 }
end, act = function(f) counter("kid8", 33) end })

shot("s09", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	return { { 13, 22.2, 3.7 }, { 13, 26.6, 3.5 }, 34, push = 0.6 }
end })

shot("s10", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("tyler", { 0, 3 }, 0, "laugh")
	cast("kid1", { -4.6, 4.4 }, 70, "smile"); cast("kid2", { 4.6, 4.4 }, -70, "content"); cast("kid3", { -1.8, 8 }, 15, "happy")
	return { { 0, -8.5, 4.6 }, { 0, 4, 4.3 }, 26, push = 1.6 }
end, act = function(f) anim("tyler", "point", 1); counter("tyler", 99); counter("kid1", 52); counter("kid2", 47); counter("kid3", 60) end, speak = "tyler" })

shot("s11", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("tyler", { 0, 3 }, 0, "laugh")
	return MT.camOn("tyler", 4.6, 4.3, 5.0, 0.7, 30, 0.7)
end, act = function(f) counter("tyler", 97) end, speak = "tyler" })

shot("s12", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("principal", { 2, 4 }, -20, "smirk"); cast("tyler", { -6, 15 }, 30, "laugh")
	return MT.camOn("principal", 7.6, 3.8, 4.5, -1.4, 28, 0.5)
end, act = function(f) anim("principal", "laugh", 1); counter("principal", 71); counter("tyler", 99) end, speak = "principal" })

---------------------------------------------------------------- grandpa (19-30 s)
shot("s13", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("grandpa", { 0, 9.6, 1 }, 0, "sad")
	return { { 0, -3.5, 3.8 }, { 0, 9, 4.8 }, 26, push = -1.6 }
end, act = function(f) counter("grandpa", 0) end })

shot("s14", { build = function()
	MT.setTownHall(); MT.family("mid-neutral-normal")
	cast("mayor", { 0, 5.5 }, 0, "smirk")
	return { { 1.5, -7, 3.4 }, { 0, 8, 5.6 }, 24, push = 1.4 }
end, act = function(f) anim("mayor", "point", 1); counter("mayor", 100) end, speak = "mayor" })

shot("s15", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("grandpa", { 0, 9.6, 1 }, 0, "sad"); cast("kid7", { -14, 1.5 }, 90, "content"); cast("kid9", { 14, 3.6 }, -90, "smile")
	return { { -4, -6, 4 }, { 0, 6, 3.8 }, 24, push = 1 }
end, act = function(f, n)
	walk("kid7", f, 1, n, { -14, 1.5 }, { 7, 1.5 }); walk("kid9", f, 1, n, { 14, 3.6 }, { -8, 3.6 })
	counter("grandpa", 0); counter("kid7", 88); counter("kid9", 76)
end })

shot("s16", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("grandpa", { 0, 9.6, 1 }, 0, "cry")
	return MT.camOn("grandpa", 4.6, 4.4, 5.0, 0.6, 30, 0.6)
end, act = function(f) counter("grandpa", 0) end })

shot("s17", { build = function()
	MT.setPorch({ summer = true }); MT.family("bright-warm-vivid")
	cast("grandpa", { -1.8, 9.6, 1 }, 35, "laugh"); cast("jay", { 2, 9.2, 1 }, -60, "happy")
	return { { 0, -3.5, 4.2 }, { 0, 9.4, 4.9 }, 28, push = 1.2 }
end, act = function(f) counter("grandpa", 64); counter("jay", 100) end, speak = "grandpa" })

shot("s18", { build = function()
	MT.setPorch({ summer = true }); MT.family("bright-warm-vivid")
	cast("grandpa", { -1.8, 9.6, 1 }, 20, "smile")
	return MT.camOn("grandpa", 4.4, 4.4, 4.95, 0.5, 30, 0.6)
end, act = function(f) counter("grandpa", 64) end, speak = "grandpa" })

shot("s19", { build = function()
	MT.setPorch({ summer = true }); MT.family("bright-warm-vivid")
	cast("grandpa", { -1.8, 9.6, 1 }, 20, "wink")
	return MT.camOn("grandpa", 3.3, 4.55, 4.75, 0.2, 30, 0.5)
end, act = function(f) counter("grandpa", 64) end })

---------------------------------------------------------------- the rule turns cruel (30-35.6 s)
shot("s20", { build = function()
	MT.setPorch({ night = true, notice = true }); MT.family("dark-neutral-vivid")
	return { { 0, 7.2, 4.4 }, { 0, 12.2, 4.6 }, 30, push = 0.8 }
end })

shot("s21", { build = function()
	MT.setPorch({ night = true }); MT.family("dark-neutral-vivid")
	MT.sign("notice2", { "NOTICE", "7 DAYS AT 0", "= SILENT FOREVER" }, { 0, 12.15, 5 }, 3.4, 2.6,
		{ bg = "#FFFFFF", border = "#E8452C", colors = { "#E8452C", "#3A3F4A", "#3A3F4A" }, sizes = { 0.3, 0.28, 0.24 } })
	return { { 0, 8.0, 5 }, { 0, 12.2, 5 }, 30, push = 0.5 }
end })

shot("s22", { build = function()
	MT.setPorch({ night = true }); MT.family("dark-neutral-vivid")
	MT.sign("cal", { "DAYS AT 0", "6 / 7" }, { -5, 12.15, 5.4 }, 3.2, 2.6, { bg = "#FFFFFF", border = "#3A3F4A", colors = { "#3A3F4A", "#E8452C" }, sizes = { 0.26, 0.5 } })
	cast("grandpa", { -1.4, 10.4, 1 }, -150, "sad"); MT.faceLight("grandpa")
	return { { -7.2, 6.6, 5 }, { -5, 12.2, 5.3 }, 28, push = 0.7 }
end, act = function(f) counter("grandpa", 0) end })

---------------------------------------------------------------- the clue (35.6-40.5 s)
shot("s23", { build = function()
	MT.setClass(); MT.family("mid-neutral-normal")
	cast("teacher", { 0, 8.2 }, 0, "angry"); cast("jay", { 2.8, 3.4 }, 180, "nervous")
	return { { -1.8, -1.5, 5 }, { 0, 8, 4.5 }, 26, push = 0.8 }
end, act = function(f) anim("teacher", "point", 1); counter("teacher", 100); counter("jay", 88) end, speak = "teacher", shake = 0.5 })

shot("s24", { build = function()
	MT.setClass(); MT.family("mid-neutral-normal")
	cast("teacher", { 0, 8.2 }, 0, "angry")
	return MT.camOn("teacher", 4.4, 4.2, 4.75, 0.5, 30, 0.8)
end, act = function(f) anim("teacher", "point", 1); counter("teacher", 100) end, speak = "teacher", shake = 0.35 })

shot("s25", { build = function()
	MT.setClass(); MT.family("mid-neutral-normal")
	cast("jay", { 0.6, 3.2 }, 0, "oh")
	return MT.camOn("jay", 4.8, 4.3, 5.2, -0.5, 30, 0.6)
end, act = function(f, n) counter("jay", MT.countUp(f, 4, n - 6, 88, 100)) end })

shot("s26", { build = function()
	MT.setClass(); MT.family("mid-neutral-normal")
	cast("jay", { 0.6, 3.2 }, 0, "shocked")
	return MT.camOn("jay", 3.8, 4.5, 4.95, 0.3, 30, 0.6)
end, act = function(f) counter("jay", 100) end })

---------------------------------------------------------------- TWIST + pause A (40.5-43 s)
shot("s27", { build = function()
	MT.setClass(); MT.family("bright-neutral-normal")
	cast("jay", { 0.6, 3.2 }, 0, "sparkle_oh")
	return MT.camOn("jay", 4.4, 4.6, 5.1, 0, 30, 1.2)
end, act = function(f) counter("jay", 100, { glow = true }) end,
	flash = function(f) return MT.flashAt(f, 1, 5, 3.5) end,          -- white flash on the twist
	shake = function(f) return MT.punch(f, 1, 2.2, 8) end })          -- and a hit that dies away

---------------------------------------------------------------- reveal + climax (43-55 s)
local ring = {}
shot("s29", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("tyler", { 0, 4 }, 0, "happy")
	ring = around(0, 4, 4.6, 6, 10)
	return { { 0, -9, 9.5 }, { 0, 4, 3.2 }, 24, push = -1.6 }
end, act = function(f) chatter(ring, f); counter("tyler", 100); for j, k in ipairs(ring) do counter(k, 40 + j * 7) end end })

shot("s30", { build = function()
	MT.setStreet(); MT.family("mid-neutral-normal")
	cast("tyler", { 0, 4 }, 0, "happy")
	ring = around(0, 4, 4.6, 6, 10)
	return MT.camOn("tyler", 4.6, 4.4, 5.0, 0.9, 30, 0.6)
end, act = function(f) chatter(ring, f); counter("tyler", 100) end })

shot("s31", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("grandpa", { 0, 9.6, 1 }, 0, "sad")
	return { { 0, -7, 4 }, { 0, 9, 4.8 }, 24, push = -2 }
end, act = function(f) counter("grandpa", 0) end })

shot("s32", { build = function()
	MT.setClass(); MT.family("mid-neutral-normal")
	MT.bellBase = MT.bell.CFrame
	cast("jay", { -12.2, 7.6 }, 10, "angry")
	return { { -10, 1.5, 5 }, { -12.8, 8.2, 5.5 }, 26, push = 0.8 }
end, act = function(f, n)
	MT.bell.CFrame = MT.bellBase * CFrame.Angles(0, 0, math.rad(22 * math.sin(f * 1.3)))
	if f < n * 0.45 then anim("jay", "wave", 1) else walk("jay", f, math.floor(n * 0.45), n, { -12.2, 7.6 }, { -9.6, 4.2 }, true) end
	counter("jay", 100)
end, shake = 0.45 })

local runners = {}
shot("s33", { build = function()
	MT.setStreet(); MT.family("mid-warm-vivid")
	runners = {}
	cast("jay", { 0, 30 }, 0, "angry")
	for j = 1, 8 do local name = "kid" .. j; cast(name, { (j % 2 == 0 and 1 or -1) * (1.2 + (j % 4) * 1.6), 34 + j * 1.6 }, 0, "laugh"); table.insert(runners, name) end
	return { { 0, -7, 1.4 }, { 0, 12, 3.4 }, 24, push = 0.6 }
end, act = function(f, n)
	MT.runAt("jay", f, 1, n, { 0, 30 }, { 0, -7 }, 3.2); counter("jay", 100)   -- runs at the low camera until he fills the frame
	for j, k in ipairs(runners) do
		local x = (j % 2 == 0 and 1 or -1) * (1.2 + (j % 4) * 1.6)
		walk(k, f, 1, n, { x, 34 + j * 1.6 }, { x, 3 + j * 1.2 }, true); counter(k, 60 + j * 4)
	end
end, shake = 0.3 })

local crowd = {}
shot("s34", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("grandpa", { 0, 9.6, 1 }, 0, "shocked")
	crowd = {}
	for j = 1, 9 do
		local row = (j - 1) // 5
		local x, y = -9.2 + ((j - 1) % 5) * 4.6 + row * 2.3, 3.4 - row * 3.4
		local name = "kid" .. j
		cast(name, { x, y }, MT.faceTo({ x, y }, { 0, 9.6 }), "happy"); table.insert(crowd, name)
	end
	return { { 8.4, 11.6, 6.4 }, { -1.5, 4.5, 3.8 }, 22, push = 1.2 }
end, act = function(f, n)
	chatter(crowd, f)
	for j, k in ipairs(crowd) do
		anim(k, ({ "wave", "point", "cheer" })[(j % 3) + 1], 1 - j * 4); counter(k, 55 + (j * 9) % 40)
	end
	counter("grandpa", MT.countUp(f, 10, n, 0, 8))
end })

shot("s35", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("grandpa", { 0, 9.6, 1 }, 0, "shocked")
	return MT.camOn("grandpa", 5.0, 4.6, 5.2, 0.6, 30, 0.9)
end, act = function(f, n)
	local v = f < 22 and MT.countUp(f, 1, 21, 8, 10) or (f < 40 and MT.countUp(f, 22, 39, 10, 50) or MT.countUp(f, 40, n - 8, 50, 100))
	counter("grandpa", v, { glow = v >= 100 })
	face("grandpa", v >= 50 and "happy" or "shocked")
end })

shot("s36", { build = function()
	MT.setPorch(); MT.family("bright-warm-vivid")
	cast("grandpa", { 0, 9.6, 1 }, 0, "smile")
	return MT.camOn("grandpa", 4.4, 4.4, 4.95, -0.5, 30, 0.6)
end, act = function(f) counter("grandpa", 100) end, speak = "grandpa" })

---------------------------------------------------------------- payoff + last line (57-63.6 s)
shot("s37", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("mom", { 3.4, 4.6 }, -25, "laugh")
	return MT.camOn("mom", 6.6, 2.6, 3.4, -1, 28, 0.5)   -- framed under her head: her number stays out of frame
end, act = function(f) anim("mom", "laugh", 1) end })

shot("s38", { build = function()
	MT.setPorch(); MT.family("mid-warm-vivid")
	cast("mom", { 3.4, 4.6 }, -25, "smile")
	return MT.camOn("mom", 3.4, 4.3, 4.35, 0.3, 30, 0.4)
end, speak = "mom" })

shot("s39", { build = function()
	MT.setPorch(); MT.family("dark-neutral-vivid")
	cast("jay", { -1, 3.2 }, 30, "oh"); MT.faceLight("jay")
	return MT.camOn("jay", 4.2, 5.4, 4.8, 0.5, 30, 0.5)
end, act = function(f) counter("jay", 100) end })

shot("s40", { build = function()
	MT.setPorch(); MT.family("dark-neutral-vivid")
	cast("mom", { 3.4, 4.6 }, -25, "smile"); MT.faceLight("mom")
	return MT.camOn("mom", 4.8, 4.8, 5.3, 0.4, 30, 0.9)
end, act = function(f) counter("mom", 2) end })

return "shots E01: " .. MT.shotIdx
