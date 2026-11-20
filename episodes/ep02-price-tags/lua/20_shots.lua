-- ep02-price-tags: 19-shot viral test episode showcasing RoboX v3 upgrades
-- (HD 1024px faces, lib12 acting + talkGesture, lib13_sets streetKit/roomKit/horizon, lib14_cam dollyZoom/orbit/twoShot/trackDof)
local MT = shared.MT
MT.resetShots()
MT.HD_FACE = true

MT.CASTV.me = { shirt = "shirt_me", pants = "pants_me", hair = "hair_floof", face = "neutral" }
MT.CASTV.dad = { shirt = "shirt_dad", pants = "pants_dad", hair = "hair_black_messy", face = "tired_slump" }
MT.CASTV.mom = { shirt = "shirt_mom", pants = "pants_mom", hair = "hair_brown_girl", face = "smile" }
MT.CASTV.bully = { shirt = "shirt_c2", pants = "pants_p2", hair = "hair_black_short", face = "smirk" }
MT.CASTV.grandpa = { shirt = "shirt_c6", pants = "pants_p3", hair = "hair_black_short", hairColor = "#D8D8DC", face = "sad" }

local function streetDay()
	MT.streetKit(160, 20)
	MT.horizon(220)
	MT.sign("town_sign", { "PRICE TOWN" }, { 0, 14, 9 }, 14, 2.8)
	MT.family("mid-neutral-normal")
end

local function streetNight()
	MT.streetKit(160, 20, { night = true })
	MT.horizon(220, "#24304A")
	MT.family("dark-neutral-vivid")
end

local function livingRoom()
	MT.roomKit(26, 22, 12, { night = true })
	MT.box("metal_box", { 2.2, 1.4, 1.2 }, { 0, 2, 0.7 }, "#4A5260", { mat = Enum.Material.Metal })
	MT.family("dark-neutral-vivid")
end

-- s01: Rule hook - kid walking toward camera down Price Town street
MT.shot("s01", {
	speak = "me",
	build = function()
		streetDay()
		MT.cast("me", { 0, 4 }, 180, "nervous")
		MT.cast("kid1", { -4, 6 }, 180, "happy")
		MT.cast("kid2", { 4, 8 }, 180, "smile")
		return { { 0, -10, 3.6 }, { 0, 0, 4.2 }, 32, push = 0.8 }
	end,
	act = function(f, n)
		MT.walkTo("me", f, 1, n, { 0, 4 }, { 0, -3 })
		MT.talkGesture("me", f)
		MT.counter("me", "$50")
		MT.counter("kid1", "$800")
		MT.counter("kid2", "$2,400")
		MT.trackDof("me")
	end,
})

-- s02: Close-up "$50"
MT.shot("s02", {
	speak = "me",
	build = function()
		streetDay()
		MT.cast("me", { 0, 0 }, 180, "sad")
		return MT.camOn("me", 4.6, 4.4, 5.0, 0.3, 28, 0.7)
	end,
	act = function(f)
		MT.actPose("me", "shrug", f, 1)
		MT.talkGesture("me", f)
		MT.counter("me", "$50")
	end,
})

-- s03: Kids at school front
MT.shot("s03", {
	build = function()
		streetDay()
		MT.cast("me", { -5, 2 }, 90, "sad")
		MT.cast("bully", { 2, 2 }, -90, "evil")
		MT.cast("kid3", { 5, 4 }, -110, "laugh")
		return MT.twoShot("me", "bully", 1, 4.5, 32)
	end,
	act = function(f)
		MT.actPose("bully", "cross_arms", f, 1)
		MT.actPose("me", "tired_slump", f, 1)
		MT.counter("me", "$50")
		MT.counter("bully", "$10,000", { glow = true })
		MT.counter("kid3", "$4,500")
	end,
})

-- s04: Bully laughs in face
MT.shot("s04", {
	speak = "bully",
	build = function()
		streetDay()
		MT.cast("bully", { 0, 0 }, 180, "laugh")
		return MT.camOn("bully", 4.4, 4.4, 5.0, -0.3, 28, 0.9)
	end,
	act = function(f)
		MT.actPose("bully", "point_accuse", f, 1)
		MT.counter("bully", "$10,000", { glow = true })
	end,
})

-- s05: Dad's weird tag
MT.shot("s05", {
	speak = "me",
	build = function()
		streetDay()
		MT.cast("dad", { 0, 0 }, 180, "exhausted")
		return MT.camOn("dad", 5.2, 4.4, 4.9, 0.4, 30, 0.5)
	end,
	act = function(f)
		MT.actPose("dad", "tired_slump", f, 1)
		MT.breathe("dad", f)
		MT.counter("dad", "$0.00", { color = Color3.fromRGB(240, 70, 50) })
	end,
})

-- s06: Zero dollars every day
MT.shot("s06", {
	build = function()
		streetDay()
		MT.cast("dad", { -3, 0 }, 90, "sad")
		MT.cast("me", { 3, 2 }, -90, "confused")
		return { { 0, -9, 3.8 }, { 0, 1, 4.3 }, 30, push = 0.6 }
	end,
	act = function(f, n)
		MT.walkTo("dad", f, 1, n, { -3, 0 }, { 2, 0 })
		MT.lookAt("me", "dad")
		MT.counter("dad", "$0.00", { color = Color3.fromRGB(240, 70, 50) })
		MT.counter("me", "$50")
	end,
})

-- s07: People treated him like a ghost
MT.shot("s07", {
	build = function()
		streetDay()
		MT.cast("dad", { 0, 0 }, 180, "heartbroken")
		MT.cast("kid4", { -4, 3 }, 180, "deadpan")
		MT.cast("kid5", { 4, 3 }, 180, "disgusted")
		return { { 0, -10, 3.8 }, { 0, 0, 4.2 }, 32, push = -0.6 }
	end,
	act = function(f)
		MT.actPose("kid5", "cross_arms", f, 1)
		MT.breathe("dad", f)
		MT.counter("dad", "$0.00", { color = Color3.fromRGB(240, 70, 50) })
	end,
})

-- s08: Grandpa's warning (planted detail)
MT.shot("s08", {
	speak = "grandpa",
	build = function()
		streetDay()
		MT.cast("grandpa", { 0, 0 }, 180, "scared")
		MT.family("mid-warm-vivid")
		return MT.camOn("grandpa", 4.5, 4.3, 4.9, 0.2, 28, 0.6)
	end,
	act = function(f)
		MT.actPose("grandpa", "whisper", f, 1)
		MT.talkGesture("grandpa", f)
	end,
})

-- s09: Tonight, Dad opens metal box
MT.shot("s09", {
	build = function()
		livingRoom()
		MT.cast("me", { -5, -4 }, 45, "suspicious")
		MT.cast("dad", { 0, 2 }, 180, "determined")
		MT.heroLight("dad")
		return { { -6, -8, 4.2 }, { 0, 2, 3.5 }, 32, push = 0.7 }
	end,
	act = function(f)
		MT.actPose("me", "sneak", f, 1)
		MT.lookAt("me", "dad")
		MT.actPose("dad", "hold_both", f, 1)
		MT.counter("dad", "$0.00", { color = Color3.fromRGB(240, 70, 50) })
	end,
})

-- s10: Close-up on kid spying
MT.shot("s10", {
	speak = "me",
	build = function()
		livingRoom()
		MT.cast("me", { 0, 0 }, 180, "shocked")
		MT.heroLight("me")
		return MT.camOn("me", 4.2, 4.4, 4.9, -0.2, 28, 0.8)
	end,
	act = function(f)
		MT.actPose("me", "sneak", f, 1)
		MT.talkGesture("me", f)
		MT.counter("me", "$50")
	end,
})

-- s11: Mom's old glowing gold tag: $10,000,000
MT.shot("s11", {
	build = function()
		livingRoom()
		MT.cast("mom", { 0, 2 }, 180, "smile")
		MT.heroLight("mom", "#FFE080", 14, 1.5)
		MT.family("bright-warm-vivid")
		return MT.camOn("mom", 5.2, 4.2, 5.2, 0.2, 30, 0.8)
	end,
	act = function(f)
		MT.breathe("mom", f)
		MT.counter("mom", "$10,000,000", { glow = true })
	end,
})

-- s12: TWIST REVEAL - Hitchcock Dolly Zoom + color shift!
MT.shot("s12", {
	handheld = 0.25,
	flash = function(f) return MT.flashAt(f, 1, 5, 2.5) end,
	build = function()
		livingRoom()
		MT.cast("me", { 0, 0 }, 180, "terrified")
		MT.heroLight("me")
		return MT.camOn("me", 5.5, 4.4, 4.8, 0, 48)
	end,
	act = function(f, n)
		MT.actSeq("me", f, { { 1, "shock" }, { 18, "step_back" } }, 5)
		MT.dollyZoom(f, n, 48, 24)
		MT.twistGrade(f, 1, n, 0.55, "#B0C8FF")
		MT.counter("me", "$50")
	end,
})

-- s13: It was a protection fee (Orbit around Dad)
MT.shot("s13", {
	build = function()
		livingRoom()
		MT.cast("dad", { 0, 0 }, 180, "heartbroken")
		MT.heroLight("dad", "#FFE0A0", 12, 1.4)
		return MT.camOn("dad", 5.8, 4.3, 4.7, 0, 34)
	end,
	act = function(f, n)
		MT.actPose("dad", "pray", f, 1)
		MT.orbit("dad", f, n, -22, 22, 5.6, -0.3, 32)
		MT.counter("dad", "$0.00", { color = Color3.fromRGB(240, 70, 50) })
	end,
})

-- s14: Dad sold his own tag for Mom
MT.shot("s14", {
	speak = "me",
	build = function()
		livingRoom()
		MT.cast("dad", { -2, 0 }, 90, "sad")
		MT.cast("mom", { 2, 0 }, -90, "heartbroken")
		MT.heroLight("dad"); MT.heroLight("mom")
		return MT.twoShot("dad", "mom", -1, 4.5, 32)
	end,
	act = function(f)
		MT.actPose("dad", "hug_self", f, 1)
		MT.lookAt("mom", "dad")
		MT.counter("dad", "$0.00", { color = Color3.fromRGB(240, 70, 50) })
		MT.counter("mom", "$10,000,000", { glow = true })
	end,
})

-- s15: Kid runs outside to warn him!
MT.shot("s15", {
	speak = "me",
	shake = 0.35,
	build = function()
		streetNight()
		MT.cast("me", { 0, 12 }, 180, "panic")
		MT.heroLight("me")
		return { { 0, -4, 2.2 }, { 0, 4, 4.0 }, 28 }
	end,
	act = function(f, n)
		MT.runAt("me", f, 1, n, { 0, 12 }, { 0, -4 }, 3.2)
		MT.actPose("me", "panic", f, 1, { upperOnly = true, weight = 0.65 })
		MT.talkGesture("me", f)
		MT.trackDof("me")
		MT.counter("me", "$50")
	end,
})

-- s16: Black van pulls up outside
MT.shot("s16", {
	shake = function(f) return MT.punch(f, 1, 1.8) end,
	build = function()
		streetNight()
		MT.box("van_body", { 12, 6, 5.5 }, { 0, 6, 3.0 }, "#15171E", { mat = Enum.Material.Metal })
		MT.box("van_hl_l", { 0.4, 1.2, 0.8 }, { -5.9, 4.2, 2.2 }, "#FFF5C0", { mat = Enum.Material.Neon })
		MT.box("van_hl_r", { 0.4, 1.2, 0.8 }, { -5.9, 7.8, 2.2 }, "#FFF5C0", { mat = Enum.Material.Neon })
		MT.cast("me", { 8, 2 }, -90, "terrified")
		MT.heroLight("me")
		return { { 10, -8, 2.4 }, { 0, 5, 3.4 }, 26, push = 0.8 }
	end,
	act = function(f)
		MT.actPose("me", "flinch", f, 1)
		MT.counter("me", "$50")
	end,
})

-- s17: Cliffhanger - tag drops to $0.01!
MT.shot("s17", {
	speak = "me",
	flash = function(f) return MT.flashAt(f, 10, 4, 3.0) end,
	shake = function(f) return MT.punch(f, 10, 2.2) end,
	build = function()
		streetNight()
		MT.cast("me", { 0, 0 }, 180, "terrified")
		MT.heroLight("me", "#FF9090", 10, 1.3)
		MT.family("dark-warm-vivid")
		return MT.camOn("me", 4.4, 4.3, 5.1, 0, 28, 1.1)
	end,
	act = function(f)
		MT.actSeq("me", f, { { 1, "shock" }, { 14, "panic" } }, 4)
		MT.talkGesture("me", f)
		MT.counter("me", f < 10 and "$50" or "$0.01", { color = Color3.fromRGB(240, 70, 50) })
	end,
})

-- s18: Final dramatic close-up hold on $0.01
MT.shot("s18", {
	handheld = 0.4,
	build = function()
		streetNight()
		MT.cast("me", { 0, 0 }, 180, "terrified")
		MT.heroLight("me", "#FF6868", 10, 1.5)
		MT.family("dark-warm-vivid")
		return MT.camOn("me", 3.6, 4.4, 5.1, 0, 26, 0.9)
	end,
	act = function(f)
		MT.actPose("me", "panic", f, 1)
		MT.counter("me", "$0.01", { color = Color3.fromRGB(240, 70, 50) })
	end,
})

-- s19: Van headlights flare out
MT.shot("s19", {
	flash = function(f) return MT.flashAt(f, 1, 6, 2.0) end,
	build = function()
		streetNight()
		MT.cast("me", { 0, 0 }, 180, "terrified")
		MT.heroLight("me", "#FF5050", 10, 1.6)
		MT.family("dark-warm-vivid")
		return MT.camOn("me", 3.1, 4.5, 5.0, 0, 24, 1.2)
	end,
	act = function(f)
		MT.actPose("me", "cry_kneel", f, 1)
		MT.counter("me", "$0.01", { color = Color3.fromRGB(240, 70, 50) })
	end,
})

return "shots: ep02 (19 shots)"
