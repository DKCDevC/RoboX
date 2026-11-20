-- ep03-red-crosswalk: 34 audio-synced shots (Gate 3 -> Gate 4 verified)
-- Rule: "In this town, the crosswalk light turns red when a bully steps onto it."
local MT = shared.MT
MT.resetShots()
MT.HD_FACE = true

-- Cast (distinct outfits & verified R6 hairs)
MT.CASTV.me = { shirt = "shirt_c8", pants = "pants_me", hair = "hair_floof", face = "smile" }
MT.CASTV.brad = { shirt = "shirt_c2", pants = "pants_p2", hair = "hair_black_messy", face = "smirk" }
MT.CASTV.owen = { shirt = "shirt_c4", pants = "pants_p1", hair = "hair_messy_anime", face = "nervous" }
MT.CASTV.coach = { shirt = "shirt_mayor", pants = "pants_dad", hair = "hair_black_short", face = "neutral" }

-- Helper: Gold patrol sash + silver whistle badge worn by narrator while on patrol
local function dressHeroPatrol(hasWhistle, hasVest)
	local a = MT.actors.me
	if not a or not a.model then return end
	local torso = a.model:FindFirstChild("Torso")
	if not torso then return end
	if hasVest ~= false then
		local sash = Instance.new("Part")
		sash.Name = "PatrolVest"
		sash.Size = Vector3.new(2.08, 1.85, 1.08)
		sash.Color = MT.C("#F5C438")
		sash.Material = Enum.Material.SmoothPlastic
		sash.CanCollide = false
		sash.CFrame = torso.CFrame
		sash.Parent = a.model
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso; w.Part1 = sash; w.Parent = sash
	end
	if hasWhistle ~= false then
		local wh = Instance.new("Part")
		wh.Name = "SilverWhistle"
		wh.Size = Vector3.new(0.32, 0.36, 0.36)
		wh.Color = MT.C("#D8DFE8")
		wh.Material = Enum.Material.Metal
		wh.CanCollide = false
		wh.CFrame = torso.CFrame * CFrame.new(0, 0.35, -0.58)
		wh.Parent = a.model
		local w2 = Instance.new("WeldConstraint")
		w2.Part0 = torso; w2.Part1 = wh; w2.Parent = wh
	end
end

-- Helper: Detailed School Bus parked by the school curb (wheels, windows, roof, bumper)
local function schoolBus(cx, cy)
	MT.box("bus_body", { 5.4, 15.0, 4.4 }, { cx, cy, 3.0 }, "#F2B628", { mat = Enum.Material.SmoothPlastic })
	MT.box("bus_hood", { 4.8, 3.2, 2.8 }, { cx, cy - 8.6, 2.2 }, "#F2B628", { mat = Enum.Material.SmoothPlastic })
	MT.box("bus_roof", { 5.2, 14.6, 0.4 }, { cx, cy, 5.3 }, "#F7F8FA", { mat = Enum.Material.SmoothPlastic })
	MT.box("bus_stripe", { 5.5, 14.8, 0.45 }, { cx, cy, 2.4 }, "#1E222B")
	MT.box("bus_windshield", { 4.4, 0.3, 1.6 }, { cx, cy - 7.45, 4.0 }, "#7CA8C8", { mat = Enum.Material.Glass })
	for _, wy in ipairs({ cy - 4.5, cy - 1.5, cy + 1.5, cy + 4.5 }) do
		MT.box("bus_win_" .. wy, { 5.52, 2.1, 1.3 }, { cx, wy, 4.0 }, "#7BA7C9", { mat = Enum.Material.Glass })
	end
	for _, wx in ipairs({ cx - 2.3, cx + 2.3 }) do
		for _, wy in ipairs({ cy - 5.5, cy + 4.5 }) do
			MT.box("bus_wheel_" .. wx .. "_" .. wy, { 0.8, 2.1, 2.1 }, { wx, wy, 1.05 }, "#1A1C22")
		end
	end
	MT.box("bus_hl_l", { 0.7, 0.3, 0.6 }, { cx - 1.6, cy - 10.25, 1.9 }, "#FFF3B0", { mat = Enum.Material.Neon })
	MT.box("bus_hl_r", { 0.7, 0.3, 0.6 }, { cx + 1.6, cy - 10.25, 1.9 }, "#FFF3B0", { mat = Enum.Material.Neon })
end

-- Helper: Crosswalk Pole with glowing Red or Green LED Signal Box & ground wash light
local function crosswalkPole(x, y, state)
	local isRed = (state == "red")
	local col = isRed and "#FF2424" or "#26EB62"
	local offCol = "#2B2E36"
	MT.box("cw_base", { 1.4, 1.4, 0.6 }, { x, y, 0.75 }, "#525866", { mat = Enum.Material.Metal })
	MT.box("cw_post", { 0.45, 0.45, 9.2 }, { x, y, 5.2 }, "#3B404A", { mat = Enum.Material.Metal })
	MT.box("cw_housing", { 2.3, 1.3, 4.4 }, { x, y, 9.2 }, "#1E222A", { mat = Enum.Material.Metal })
	-- Top = RED lamp, Bottom = GREEN lamp
	MT.box("cw_lamp_red", { 1.6, 1.45, 1.55 }, { x, y, 10.15 }, isRed and col or offCol, {
		mat = isRed and Enum.Material.Neon or Enum.Material.SmoothPlastic,
	})
	MT.box("cw_lamp_grn", { 1.6, 1.45, 1.55 }, { x, y, 8.25 }, (not isRed) and col or offCol, {
		mat = (not isRed) and Enum.Material.Neon or Enum.Material.SmoothPlastic,
	})
	local housing = MT.root():FindFirstChild("cw_lamp_" .. (isRed and "red" or "grn"))
	if housing then
		local pl = Instance.new("PointLight")
		pl.Color = MT.C(col)
		pl.Range = 22
		pl.Brightness = isRed and 3.4 or 2.2
		pl.Shadows = false
		pl.Parent = housing
	end
end

-- Oak Street Crosswalk + School Gate + Bus Stop Bench
local function oakStreet(lightState, mood, withBus)
	MT.streetKit(180, 20)
	MT.horizon(230)
	-- Crosswalk white stripes across asphalt (y = -2..+2, x = -9..+9)
	for x = -8, 8, 2.6 do
		MT.box("cw_stripe_" .. x, { 1.35, 5.2, 0.08 }, { x, 0, 0.04 }, "#F7F8FC")
	end
	-- Crosswalk Signal Pole on right curb facing down road
	crosswalkPole(10.8, 3.6, lightState or "green")
	-- School building + gate + OAK STREET sign behind on left sidewalk
	MT.box("school_wall", { 16, 44, 18 }, { -26, 8, 9 }, "#C86B54", { mat = Enum.Material.Brick })
	MT.box("school_trim", { 16.4, 44.4, 1.6 }, { -26, 8, 17.6 }, "#E9DFCC")
	MT.box("school_door", { 0.5, 6.0, 9.5 }, { -18, 2, 5.2 }, "#5A3B28")
	MT.sign("oak_sign", { "OAK STREET", "SCHOOL CROSSING" }, { -16.8, 14, 12.5 }, 11.5, 3.2, "#F7E26B", "#1A1E26")
	-- Bus stop bench + yellow pole on left curb
	MT.box("bench_seat", { 2.2, 7.0, 0.45 }, { -14.0, -10, 1.65 }, "#D98A3C", { mat = Enum.Material.Wood })
	MT.box("bench_leg1", { 1.8, 0.4, 1.2 }, { -14.0, -13.0, 0.9 }, "#383D47")
	MT.box("bench_leg2", { 1.8, 0.4, 1.2 }, { -14.0, -7.0, 0.9 }, "#383D47")
	MT.box("bus_sign_post", { 0.3, 0.3, 7.5 }, { -11.5, -14.5, 4.2 }, "#4B5260")
	MT.sign("bus_sign", { "BUS STOP" }, { -11.5, -14.5, 8.2 }, 4.2, 1.6, "#F5CE42", "#1A1C22")
	if withBus then schoolBus(-5.6, -24) end
	MT.family(mood or "mid-neutral-normal")
end

-- Elm Street Crosswalk (distinct blue-clapboard neighborhood houses + green/red beacon)
local function elmStreet(lightState, mood)
	MT.streetKit(180, 20)
	MT.horizon(230)
	for x = -8, 8, 2.6 do
		MT.box("elm_stripe_" .. x, { 1.35, 5.2, 0.08 }, { x, 0, 0.04 }, "#F7F8FC")
	end
	crosswalkPole(-10.8, 4.2, lightState or "green")
	MT.box("elm_house1", { 14, 18, 13 }, { 24, 10, 6.5 }, "#6E9BC8")
	MT.box("elm_roof1", { 15, 19, 3.5 }, { 24, 10, 14.5 }, "#404B5C")
	MT.box("elm_house2", { 14, 18, 12 }, { -24, 14, 6.0 }, "#E4C678")
	MT.sign("elm_sign", { "ELM STREET" }, { 11.4, 10, 10.5 }, 8.5, 2.2, "#2A8F4D", "#FFFFFF")
	MT.family(mood or "mid-warm-vivid")
end

-- Bedroom / Study desk for Whistle polish insert (s08)
local function bedroomSet()
	MT.roomKit(20, 18, 11, { night = false })
	MT.box("desk_top", { 7.5, 3.8, 0.4 }, { 0, 2, 2.6 }, "#A67449", { mat = Enum.Material.Wood })
	MT.box("desk_leg1", { 0.4, 3.4, 2.4 }, { -3.4, 2, 1.2 }, "#734F30")
	MT.box("desk_leg2", { 0.4, 3.4, 2.4 }, { 3.4, 2, 1.2 }, "#734F30")
	-- Big shiny silver patrol whistle prop on desk
	MT.box("whistle_body", { 1.2, 0.75, 0.75 }, { 0, 1.5, 3.18 }, "#DCE4EE", { mat = Enum.Material.Metal })
	MT.box("whistle_tip", { 0.8, 0.45, 0.38 }, { -0.85, 1.5, 3.25 }, "#DCE4EE", { mat = Enum.Material.Metal })
	MT.box("whistle_ring", { 0.35, 0.55, 0.55 }, { 0.7, 1.5, 3.2 }, "#F5C438", { mat = Enum.Material.Metal })
	MT.family("mid-warm-vivid")
end

-- s01: 0.00-2.43 Hook: "In this town, the crosswalk light turns red"
MT.shot("s01", {
	speak = "me",
	build = function()
		oakStreet("green", "mid-neutral-normal", true)
		MT.cast("me", { 2, -6 }, 0, "smile")
		dressHeroPatrol(true, true)
		MT.cast("kid1", { -4, 4 }, 0, "happy")
		MT.cast("kid2", { 6, 6 }, 0, "smile")
		return { { 4.5, -18, 2.8 }, { 3.5, 2, 5.2 }, 34, push = 0.8 }
	end,
	act = function(f, n)
		MT.walkTo("me", f, 1, n, { 2, -6 }, { 2, -1 })
		MT.talkGesture("me", f)
		if f >= math.floor(n * 0.65) then
			local lr = MT.root():FindFirstChild("cw_lamp_red")
			local lg = MT.root():FindFirstChild("cw_lamp_grn")
			if lr then lr.Color = MT.C("#FF2424"); lr.Material = Enum.Material.Neon end
			if lg then lg.Color = MT.C("#2B2E36"); lg.Material = Enum.Material.SmoothPlastic end
		end
	end,
})

-- s02: 2.43-4.03 "when a bully steps onto it."
MT.shot("s02", {
	speak = "me",
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("brad", { 4, -2 }, 0, "evil")
		return MT.camOn("brad", 5.0, 3.8, 4.4, -0.5, 30, 0.9)
	end,
	act = function(f, n)
		MT.walkTo("brad", f, 1, n, { 4, -2 }, { 4, 0.5 })
		MT.actPose("brad", "cross_arms", f, 1, { upperOnly = true, weight = 0.7 })
		MT.trackDof("brad")
	end,
})

-- s03: 4.03-6.02 Stake: "I guarded Oak Street for that gold vest."
MT.shot("s03", {
	speak = "me",
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("me", { -12.5, -1, 0.45 }, 90, "happy")
		dressHeroPatrol(true, true)
		return MT.camOn("me", 4.6, 3.9, 4.2, 0.3, 28, 0.7)
	end,
	act = function(f)
		MT.actPose("me", "point_accuse", f, 1, { weight = 0.6 })
		MT.talkGesture("me", f)
		MT.trackDof("me")
	end,
})

-- s04: 6.02-8.11 "Last month, Brad stepped off the curb."
MT.shot("s04", {
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("brad", { 8, -3 }, -90, "smirk")
		return { { -3, -10, 2.6 }, { 4, -1, 4.0 }, 32, push = 0.6 }
	end,
	act = function(f, n)
		MT.walkTo("brad", f, 1, n, { 8, -3 }, { 3, -1 })
		MT.breathe("brad", f)
	end,
})

-- s05: 8.11-9.46 "The sign flashed red."
MT.shot("s05", {
	shake = function(f) return MT.punch(f, 1, 2.0) end,
	flash = function(f) return MT.flashAt(f, 1, 4, 2.2) end,
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("brad", { 6, -1 }, 20, "shocked")
		MT.heroLight("brad", "#FF5050", 12, 1.4)
		return MT.camOn("brad", 4.4, 5.2, 4.6, 0.4, 28, 1.0)
	end,
	act = function(f)
		MT.actPose("brad", "flinch", f, 1)
		MT.trackDof("brad")
	end,
})

-- s06: 9.46-10.93 INS: "Brad dropped his lunchbox."
MT.shot("s06", {
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("brad", { 5, 1 }, 0, "scared")
		MT.box("lunchbox", { 1.4, 1.0, 0.7 }, { 5.4, -2.0, 0.35 }, "#E04438")
		MT.cast("kid1", { -4, 4 }, 20, "laugh")
		MT.cast("kid2", { -1, 5 }, -15, "laugh")
		return { { 5.4, -6.5, 4.8 }, { 5.4, -1.8, 0.5 }, 30, push = 0.7 }
	end,
	act = function(f, n)
		local z = math.max(0.35, 2.4 - 2.05 * math.min(1, f / math.max(1, n * 0.5)))
		local lb = MT.root():FindFirstChild("lunchbox")
		if lb then lb.Position = Vector3.new(5.4, z, 2.0) end
		MT.actPose("kid1", "point_accuse", f, 1)
	end,
})

-- s07: 10.93-12.61 "Honestly, I loved that job."
MT.shot("s07", {
	speak = "me",
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("me", { 6, -1 }, -70, "happy")
		dressHeroPatrol(true, true)
		MT.cast("kid1", { -3, 0 }, 90, "smile")
		MT.cast("kid2", { -6, -1 }, 90, "happy")
		return { { 0, -13, 3.6 }, { 1, 0, 3.6 }, 32, push = 0.5 }
	end,
	act = function(f, n)
		MT.walkTo("kid1", f, 1, n, { -3, 0 }, { 3, 0 })
		MT.walkTo("kid2", f, 1, n, { -6, -1 }, { 0, -1 })
		MT.talkGesture("me", f)
	end,
})

-- s08: 12.61-14.46 INS: "I polished my whistle every night."
MT.shot("s08", {
	build = function()
		bedroomSet()
		MT.cast("me", { 0, 4.5 }, 0, "content")
		dressHeroPatrol(false, false)
		MT.heroLight("me", "#FFE2A0", 12, 1.3)
		return { { 1.8, -1.8, 4.4 }, { 0, 1.5, 3.2 }, 26, push = 0.7 }
	end,
	act = function(f)
		MT.actPose("me", "hold_both", f, 1)
		MT.breathe("me", f)
	end,
})

-- s09: 14.46-16.28 "Then Owen joined my bus in March."
MT.shot("s09", {
	build = function()
		oakStreet("green", "mid-neutral-normal", true)
		MT.cast("owen", { -13.5, -12, 0.45 }, 40, "nervous")
		return { { -6, -19, 3.6 }, { -12.5, -11, 4.0 }, 30, push = 0.5 }
	end,
	act = function(f, n)
		MT.walkTo("owen", f, 1, n, { -13.5, -12, 0.45 }, { -13.5, -6, 0.45 })
	end,
})

-- s10: 16.28-18.53 "Every morning, that light buzzed red."
MT.shot("s10", {
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("me", { 3, 0 }, -90, "confused")
		dressHeroPatrol(true, true)
		MT.cast("owen", { -5, 1 }, -90, "scared")
		return { { -1, -15, 6.2 }, { 1, 1, 4.8 }, 34, push = -0.7 }
	end,
	act = function(f, n)
		MT.walkTo("me", f, 1, n, { 3, 0 }, { 6, 0 })
		MT.walkTo("owen", f, 1, n, { -5, 1 }, { -1, 1 })
	end,
})

-- s11: 18.53-20.43 Brad: "Keep Red Light Owen off our street!"
MT.shot("s11", {
	speak = "brad",
	build = function()
		oakStreet("red", "mid-neutral-normal", true)
		MT.cast("brad", { -13.5, -8, 0.45 }, 90, "furious")
		return MT.camOn("brad", 4.5, 3.6, 4.5, -0.3, 28, 0.8)
	end,
	act = function(f)
		MT.actPose("brad", "point_accuse", f, 1)
		MT.talkGesture("brad", f)
		MT.trackDof("brad")
	end,
})

-- s12: 20.43-21.87 "I kinda laughed along too."
MT.shot("s12", {
	speak = "me",
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("me", { -12.5, -2, 0.45 }, 45, "laugh")
		dressHeroPatrol(true, true)
		return MT.camOn("me", 4.8, 4.3, 4.8, 0.2, 28)
	end,
	act = function(f, n)
		MT.orbit("me", f, n, -14, 14, 4.8, 0.1, 28)
		MT.talkGesture("me", f)
	end,
})

-- s13: 21.87-23.42 "I shoved Owen behind the line."
MT.shot("s13", {
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("me", { -8, -1 }, -90, "smirk")
		dressHeroPatrol(true, true)
		MT.cast("owen", { -11.8, -1, 0.45 }, 90, "scared")
		return { { -9.5, -9, 3.6 }, { -10, -1, 3.8 }, 32, push = 0.6 }
	end,
	act = function(f)
		MT.actPose("me", "point_accuse", f, 1)
		MT.actPose("owen", "flinch", f, 1)
	end,
})

-- s14: 23.42-25.67 "'Stay behind the stripe, dude,' I joked."
MT.shot("s14", {
	speak = "me",
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("me", { -11.8, -1, 0.45 }, 135, "smirk")
		dressHeroPatrol(true, true)
		MT.cast("owen", { -14.8, 1, 0.45 }, 45, "sad")
		return MT.camOn("me", 4.4, 4.2, 4.7, 0.3, 28, 0.7)
	end,
	act = function(f)
		MT.talkGesture("me", f)
		MT.trackDof("me")
	end,
})

-- s15: 25.67-27.63 "Same loud buzz at 7:45."
MT.shot("s15", {
	shake = 0.25,
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.sign("clock_745", { "07:45 AM" }, { 10.8, 3.6, 13.0 }, 5.5, 1.8, "#1A1C24", "#FF4040")
		MT.cast("me", { 4, 0 }, 0, "smirk")
		dressHeroPatrol(true, true)
		MT.cast("owen", { -3, 2 }, 0, "sad")
		return { { 3, -12, 6.0 }, { 4, 2, 5.2 }, 30, push = 0.6 }
	end,
	act = function(f)
		MT.actPose("me", "shrug", f, 1)
		MT.breathe("owen", f)
	end,
})

-- s16: 27.63-29.83 "Coach Miller checked his clipboard Thursday."
MT.shot("s16", {
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("coach", { -14, 2, 0.45 }, 90, "suspicious")
		MT.box("clipboard", { 0.3, 1.4, 1.8 }, { -12.7, 2, 3.5 }, "#6E4D32")
		return MT.camOn("coach", 4.8, 5.2, 4.3, -0.3, 30, 0.6)
	end,
	act = function(f)
		MT.actPose("coach", "hold_both", f, 1)
		MT.breathe("coach", f)
		MT.trackDof("coach")
	end,
})

-- s17: 29.83-32.00 Coach: "Oak Street stayed green before March."
MT.shot("s17", {
	speak = "coach",
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("coach", { -14, 2, 0.45 }, 60, "neutral")
		return MT.camOn("coach", 4.2, 3.8, 4.7, 0.2, 28, 0.8)
	end,
	act = function(f)
		MT.talkGesture("coach", f)
		MT.trackDof("coach")
	end,
})

-- s18: 32.00-35.18 "Friday morning, I came at 7:30. Zero kids."
MT.shot("s18", {
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.sign("clock_730", { "07:30 AM" }, { 10.8, 3.6, 13.0 }, 5.5, 1.8, "#1A1C24", "#40FF80")
		MT.cast("me", { -13.0, -5, 0.45 }, 135, "confused")
		dressHeroPatrol(true, true)
		return { { -3, -18, 7.2 }, { -11, -3, 3.8 }, 34, push = 0.7 }
	end,
	act = function(f)
		MT.actPose("me", "look_around", f, 1)
	end,
})

-- s19: 35.18-37.49 "I saw Owen on Elm Street. Green light."
MT.shot("s19", {
	build = function()
		elmStreet("green", "mid-warm-vivid")
		MT.cast("owen", { -6, 0 }, 90, "happy")
		return { { 0, -16, 4.0 }, { 0, 1, 4.2 }, 32, push = 0.9 }
	end,
	act = function(f, n)
		MT.walkTo("owen", f, 1, n, { -6, 0 }, { 4, 0 })
	end,
})

-- s20: 37.49-39.13 "I stepped onto Oak Street alone."
MT.shot("s20", {
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("me", { -4, 0 }, 90, "smirk")
		dressHeroPatrol(true, true)
		return { { 2, -10, 2.8 }, { 1, 0, 3.8 }, 32, push = 0.6 }
	end,
	act = function(f, n)
		MT.walkTo("me", f, 1, n, { -4, 0 }, { 1, 0 })
	end,
})

-- s21: 39.13-42.46 TWIST: "The light blasted red right in my face." + 1.0s pause A
MT.shot("s21", {
	handheld = 0.25,
	flash = function(f) return MT.flashAt(f, 1, 5, 2.6) end,
	shake = function(f) return MT.punch(f, 1, 2.2) end,
	build = function()
		oakStreet("red", "dark-neutral-vivid", false)
		MT.cast("me", { 1, 0 }, 0, "terrified")
		dressHeroPatrol(true, true)
		MT.heroLight("me", "#FF3B3B", 14, 1.8)
		return MT.camOn("me", 5.0, 3.9, 4.8, 0, 48)
	end,
	act = function(f, n)
		MT.actSeq("me", f, { { 1, "shock" }, { 24, "panic" } }, 5)
		MT.dollyZoom(f, n, 48, 24)
		MT.twistGrade(f, 1, n, 0.55, "#B0C8FF")
		MT.trackDof("me")
	end,
})

-- s22: 42.46-45.10 INS: "Wait. I stepped one foot back onto the curb."
MT.shot("s22", {
	build = function()
		oakStreet("red", "dark-neutral-vivid", false)
		MT.cast("me", { 9.0, 0 }, 90, "scared")
		dressHeroPatrol(true, true)
		return { { 8.5, -5.5, 3.8 }, { 9.8, 0, 0.8 }, 28, push = 0.5 }
	end,
	act = function(f, n)
		MT.walkTo("me", f, 1, n, { 9.0, 0 }, { 11.2, 0, 0.45 })
	end,
})

-- s23: 45.10-45.98 "Bright green."
MT.shot("s23", {
	flash = function(f) return MT.flashAt(f, 1, 4, 2.0) end,
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("me", { 11.4, 0, 0.45 }, 0, "shocked")
		dressHeroPatrol(true, true)
		MT.heroLight("me", "#58FF88", 12, 1.4)
		return MT.camOn("me", 4.5, 3.6, 4.9, 0.3, 28, 0.9)
	end,
	act = function(f)
		MT.actPose("me", "shock", f, 1)
		MT.trackDof("me")
	end,
})

-- s24: 45.98-47.45 "I stepped onto the paint again."
MT.shot("s24", {
	build = function()
		oakStreet("green", "dark-neutral-vivid", false)
		MT.cast("me", { 11.4, 0, 0.45 }, -90, "nervous")
		dressHeroPatrol(true, true)
		return { { 4, -9, 3.6 }, { 8, 0, 3.5 }, 32, push = 0.6 }
	end,
	act = function(f, n)
		MT.walkTo("me", f, 1, n, { 11.4, 0, 0.45 }, { 8.0, 0, 0 })
	end,
})

-- s25: 47.45-48.23 "Red again."
MT.shot("s25", {
	shake = function(f) return MT.punch(f, 1, 2.4) end,
	flash = function(f) return MT.flashAt(f, 1, 4, 2.5) end,
	build = function()
		oakStreet("red", "dark-warm-vivid", false)
		MT.cast("me", { 8.0, 0 }, 0, "terrified")
		dressHeroPatrol(true, true)
		MT.heroLight("me", "#FF2424", 12, 1.8)
		return MT.camOn("me", 3.6, 4.5, 4.9, 0, 26, 0.8)
	end,
	act = function(f)
		MT.actPose("me", "flinch", f, 1)
		MT.trackDof("me")
	end,
})

-- s26: 48.23-51.49 "Twenty kids stared from the bus stop. Nobody moved."
MT.shot("s26", {
	build = function()
		oakStreet("red", "dark-neutral-vivid", true)
		MT.cast("kid1", { -12.0, -8, 0.45 }, 90, "stare")
		MT.cast("kid2", { -12.0, -4, 0.45 }, 90, "shocked")
		MT.cast("kid3", { -12.0, 0, 0.45 }, 90, "stare")
		MT.cast("kid4", { -12.0, 4, 0.45 }, 90, "shocked")
		return { { -2, -14, 5.2 }, { -12, -2, 3.8 }, 34, push = -0.8 }
	end,
	act = function(f)
		MT.breathe("kid1", f); MT.breathe("kid2", f)
		MT.breathe("kid3", f); MT.breathe("kid4", f)
	end,
})

-- s27: 51.49-53.02 Brad: "Look, nobody's behind him."
MT.shot("s27", {
	speak = "brad",
	build = function()
		oakStreet("red", "dark-neutral-vivid", false)
		MT.cast("brad", { -12.5, 2, 0.45 }, 90, "shocked")
		return MT.camOn("brad", 4.6, 3.7, 4.6, -0.3, 28, 0.8)
	end,
	act = function(f)
		MT.actPose("brad", "point_accuse", f, 1)
		MT.talkGesture("brad", f)
		MT.trackDof("brad")
	end,
})

-- s28: 53.02-55.78 "I literally stood frozen there for five whole seconds."
MT.shot("s28", {
	build = function()
		oakStreet("red", "dark-warm-vivid", false)
		MT.cast("me", { 2, 0 }, 0, "heartbroken")
		dressHeroPatrol(true, true)
		MT.heroLight("me", "#FF5050", 12, 1.5)
		return MT.camOn("me", 5.0, 4.4, 4.7, 0, 28)
	end,
	act = function(f, n)
		MT.actPose("me", "tired_slump", f, 1)
		MT.orbit("me", f, n, -16, 16, 5.0, 0, 28)
		MT.trackDof("me")
	end,
})

-- s29: 55.78-58.28 "Coach Miller walked out and picked up his red pen."
MT.shot("s29", {
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("coach", { -13.5, 2, 0.45 }, 90, "sad")
		MT.box("red_pen", { 0.25, 0.25, 1.1 }, { -12.2, 2.3, 3.2 }, "#E63232")
		return MT.camOn("coach", 4.8, 4.3, 4.6, 0.3, 30, -0.5)
	end,
	act = function(f)
		MT.actPose("coach", "hold_both", f, 1)
		MT.trackDof("coach")
	end,
})

-- s30: 58.28-60.81 INS: "My silver whistle felt kinda heavy around my neck now."
MT.shot("s30", {
	build = function()
		oakStreet("red", "mid-neutral-normal", false)
		MT.cast("me", { -11.5, 0, 0.45 }, 45, "sad")
		dressHeroPatrol(true, true)
		return MT.camOn("me", 3.4, 3.2, 3.6, 0.1, 26, 0.6)
	end,
	act = function(f)
		MT.actPose("me", "hug_self", f, 1)
		MT.trackDof("me")
	end,
})

-- s31: 60.81-63.35 "I handed Coach my patrol clipboard by the school gate."
MT.shot("s31", {
	build = function()
		oakStreet("green", "mid-neutral-normal", false)
		MT.cast("me", { -12.0, 0, 0.45 }, -90, "sad")
		dressHeroPatrol(false, false)
		MT.cast("coach", { -15.5, 0, 0.45 }, 90, "sad")
		MT.box("clipboard", { 0.3, 1.3, 1.7 }, { -13.6, 0, 3.5 }, "#6E4D32")
		return MT.twoShot("me", "coach", -1, 4.6, 30)
	end,
	act = function(f)
		MT.actPose("me", "tired_slump", f, 1)
		MT.actPose("coach", "hold_both", f, 1)
	end,
})

-- s32: 63.35-67.26 "Across the street, Owen walked calmly under green crosswalk lights."
MT.shot("s32", {
	build = function()
		elmStreet("green", "mid-warm-vivid")
		MT.cast("owen", { -7, 0 }, 90, "happy")
		return { { 0, -14, 3.8 }, { 0, 1, 4.2 }, 32, push = 0.6 }
	end,
	act = function(f, n)
		MT.walkTo("owen", f, 1, n, { -7, 0 }, { 5, 0 })
	end,
})

-- s33: 67.26-69.65 "I walked down Oak Street alone." + 0.8s pause B
MT.shot("s33", {
	build = function()
		oakStreet("green", "dark-neutral-vivid", false)
		MT.cast("me", { 0, 6 }, 0, "heartbroken")
		dressHeroPatrol(true, false)
		return { { 0, -14, 5.2 }, { 0, 0, 3.8 }, 32, push = 0.7 }
	end,
	act = function(f, n)
		MT.walkTo("me", f, 1, n, { 0, 6 }, { 0, -4 })
	end,
})

-- s34: 69.65-73.40 LAST LINE: "I gripped my whistle, and Elm Street buzzed bright red."
MT.shot("s34", {
	flash = function(f) return MT.flashAt(f, 12, 5, 2.4) end,
	shake = function(f) return MT.punch(f, 12, 1.6) end,
	build = function()
		elmStreet("red", "dark-warm-vivid")
		MT.cast("me", { 0, -2 }, 0, "terrified")
		dressHeroPatrol(true, false)
		MT.heroLight("me", "#FF4040", 14, 1.8)
		return { { -3, -12, 2.8 }, { -1, 1, 4.5 }, 34, push = -1.0 }
	end,
	act = function(f)
		MT.actPose("me", "shock", f, 1)
		MT.trackDof("me")
	end,
})

return "shots: ep03 (34 shots)"
