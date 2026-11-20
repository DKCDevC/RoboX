-- ep04-test5s SETS (stage 2): Oak Street crosswalk, reused from ep03. Registers the set sheet previews.
local MT = shared.MT

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
		pl.Range = 9
		pl.Brightness = isRed and 3.4 or 2.2
		pl.Shadows = false
		pl.Parent = housing
	end
end

-- Oak Street Crosswalk + School Gate + Bus Stop Bench
local function oakStreetOld(lightState, mood, withBus)
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
	MT.family(mood or "mid-neutral-normal")
end

local function oakStreet(lightState, mood)
	MT.townStreet({})
	crosswalkPole(10.8, 3.6, lightState or "green")
	MT.family(mood or "mid-warm-vivid")
end
MT.oakStreet = oakStreet   -- shots.lua calls it

MT.setPreview("oak", function() oakStreet("green", "mid-warm-vivid") end, {
	cast = { { "me", { 2.6, -0.6 }, -70, "smile" }, { "brad", { -4, 0.4 }, 90, "smirk" } },
	cams = { wide = { { 0, -20, 5.5 }, { 0, 0, 3.0 }, 34 }, low = { { -4, -9, 1.6 }, { 2, 0, 3.2 }, 32 }, top = { { 0, -0.5, 40 }, { 0, 0, 0 }, 40 } },
})
return "sets loaded"
