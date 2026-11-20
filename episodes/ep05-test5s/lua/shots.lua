-- ep05-test5s STORYBOARD (stage 3): 5 shots, 5.0 s, 260 wpm. Neon palette; push-ins on all, a Dutch roll on s05; readable sign props.
local MT = shared.MT
MT.resetShots()
local street = MT.neonStreet
local PINK, CYAN = Color3.fromRGB(255, 60, 160), Color3.fromRGB(40, 220, 255)

-- s01 0.00-0.60 "In this city,"  the whole street, neon on dark, the hero small in front
MT.shot("s01", {
	build = function()
		street()
		MT.cast("me", { 1.8, -6 }, 180, "smile")
		return { { 0, -16, 3.2 }, { 0, 26, 7 }, 36, push = 0.8 }
	end,
	act = function(f, n) end,
})

-- s02 0.60-1.90 "the neon signs read your mind."  the sign close, cyan/violet glow
MT.shot("s02", {
	build = function()
		street()
		return { { 1.0, 4, 7.4 }, { 0, 12, 8 }, 30, push = 0.9 }
	end,
	act = function(f, n) end,
})

-- s03 1.90-3.57 "Last night, mine said my secret."  hero looks up, the secret sign behind him
MT.shot("s03", {
	roll = function(f) return MT.rollRamp(f, 1, 50, 0, -4) end,
	portrait = { key = Color3.fromRGB(255, 80, 170), rim = Color3.fromRGB(60, 200, 255) },
	build = function()
		street({ noMind = true })
		MT.cast("me", { 0, 4 }, 0, "scared")
		local sg = MT.sign("secret", { "I STILL", "SLEEP WITH", "A NIGHTLIGHT" }, { -1.7, 9, 9.4 }, 4.6, 3.4, { bg = "#0C0612", colors = { "#FF3C9F", "#28DCFF" } }).SurfaceGui; sg.LightInfluence = 0; sg.Brightness = 2
		return MT.camOn("me", 4.0, 4.6, 5.3, 0.9, 30, 0.8)
	end,
	act = function(f, n) MT.actPose("me", "flinch", f, 1) end,
})

-- s04 3.57-4.17 "Everyone"  the crowd turns to look
MT.shot("s04", {
	build = function()
		street()
		MT.cast("kid1", { -4, 1 }, 180, "oh"); MT.cast("kid2", { -1.4, 2 }, 180, "shocked"); MT.cast("kid3", { 1.6, 1 }, 180, "oh"); MT.cast("kid4", { 4.2, 2 }, 180, "laugh")
		return { { 0, 12, 2.6 }, { 0, 0, 3.6 }, 34, push = 0.7 }
	end,
	act = function(f, n) end,
})

-- s05 4.17-5.00 "saw it."  hero's face, shocked; Dutch roll and a soft punch
MT.shot("s05", {
	shake = function(f) return MT.punch(f, 1, 0.6, 9) end,
	roll = function(f) return MT.rollRamp(f, 1, 25, 0, 6) end,
	portrait = { key = Color3.fromRGB(255, 80, 170), rim = Color3.fromRGB(60, 200, 255) },
	build = function()
		street()
		MT.cast("me", { 0, 0 }, 0, "shocked")
		return MT.camOn("me", 3.4, 4.6, 5.0, 0.5, 28, 0.9)
	end,
	act = function(f, n) MT.actPose("me", "flinch", f, 1) end,
})
return "shots: s01 s02 s03 s04 s05"
