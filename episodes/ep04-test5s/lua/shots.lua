-- ep04-test5s STORYBOARD (stage 3): 5 shots, 5.0 s, on the approved cast and set. Fast read, 248 wpm.
local MT = shared.MT
MT.resetShots()
local oak = MT.oakStreet

-- s01 0.00-0.63 "In this town,"  wide, the crosswalk and the narrator, slow push
MT.shot("s01", {
	speak = "me",
	build = function()
		oak("green", "mid-warm-vivid")
		MT.cast("me", { 1.8, -0.6 }, -70, "happy")
		MT.cast("brad", { -2.4, 0.4 }, 60, "smirk")
		return { { 0, -13, 3.6 }, { 1, 0, 3.6 }, 32, push = 0.5 }
	end,
	act = function(f, n) MT.talkGesture("me", f) end,
})

-- s02 0.63-1.30 "the crosswalk turns red"  low close on the signal, push
MT.shot("s02", {
	build = function()
		oak("red", "mid-warm-vivid")
		return { { 5.5, -3, 6.2 }, { 10.8, 3.6, 9.0 }, 30, push = 0.7 }
	end,
	act = function(f, n) end,
})

-- s03 1.30-2.07 "for bullies."  Brad's smirk, close, push
MT.shot("s03", {
	build = function()
		oak("green", "mid-warm-vivid")
		MT.cast("brad", { -1, 0.4 }, 0, "smirk")
		return MT.camOn("brad", 3.6, 4.4, 5.0, 0.6, 30, 0.6)
	end,
	act = function(f, n) MT.anim("brad", "idle", 1) end,
})

-- s04 2.07-3.67 "Last Monday, Brad stepped on it."  Brad walks onto the crosswalk, 8 studs in 1.0 s (8.3 studs/s), then stands
MT.shot("s04", {
	build = function()
		oak("green", "mid-warm-vivid")
		MT.cast("brad", { -4, 0.4 }, 90, "smirk")
		return { { 0, -13, 2.2 }, { 0, 0.4, 3.0 }, 34, push = 0.5 }
	end,
	act = function(f, n) MT.walkTo("brad", f, 1, 30, { -4, 0.4 }, { 4, 0.4 }) end   -- 8 studs in 1.0 s, then he stands on the crosswalk,
})

-- s05 3.67-5.00 "Everything went dark."  red, dark, Brad flinches; a Dutch roll that turns 6 degrees; shake on the first frame
MT.shot("s05", {
	shake = function(f) return MT.punch(f, 1, 0.6, 9) end,   -- was 1.8 over 6 frames: the whole frame (head and hair) jumped sideways
	roll = function(f) return MT.rollRamp(f, 1, 40, 0, 6) end,
	build = function()
		oak("red", "mid-warm-vivid")
		-- the sun goes out: much darker, red from the signal; the dusk sky stays so the shot keeps depth (a night sky was just black)
		local L = game:GetService("Lighting"); L.ExposureCompensation = L.ExposureCompensation - 1.0; MT.famExp = L.ExposureCompensation
		local cc = L:FindFirstChild("MTColor"); if cc then cc.TintColor = Color3.fromRGB(255, 150, 130); cc.Saturation = 0.3 end
		MT.cast("brad", { 4, 0 }, 0, "terrified")
		MT.heroLight("brad", "#FF2424", 12, 1.8)
		return MT.camOn("brad", 3.6, 4.5, 4.9, 0, 26, 0.8)
	end,
	act = function(f, n) MT.actPose("brad", "flinch", f, 1); MT.trackDof("brad") end,
})
return "shots: s01 s02 s03 s04 s05"
