-- lib15_world (v3.2, 2026-11-20): a world that looks built, not blocked out. Studied from the @Gneef frames (gneef-study.md section 10):
-- real surface texture everywhere (terrain grass and asphalt, brick, wood, concrete), a warm muted palette, distant hills in haze,
-- trees, fences, lit windows, warm lamps. Load order: after lib14_cam (load.py).
--   MT.ground(o)            terrain lawn + asphalt road (o.grass, o.road colours, o.roadW)
--   MT.hills(o)             distant rolling hills of terrain behind and beside the street
--   MT.tree(name, x, y, s)  trunk + leaf balls;  MT.house(name, x, y, o);  MT.fence(name, x, y0, y1);  MT.lampPost(name, x, y)
--   MT.townStreet(o)        all of it: ground, sidewalks, curbs, dashes, crosswalk, houses, trees, fences, lamps, hills
local MT = shared.MT
local RGB = Color3.fromRGB
local T = workspace.Terrain
local M = Enum.Material

MT.PAL = {
	brick = RGB(150, 84, 66), cream = RGB(214, 196, 156), sage = RGB(140, 154, 124), slate = RGB(108, 124, 148), clay = RGB(178, 120, 84),
	roof = RGB(74, 62, 58), roof2 = RGB(96, 72, 60), trim = RGB(232, 224, 206), door = RGB(86, 52, 40),
	walk = RGB(184, 172, 154), curb = RGB(150, 140, 126), stripe = RGB(232, 224, 206), dash = RGB(216, 180, 84),
	grass = RGB(98, 112, 58), road = RGB(72, 68, 66), leaf1 = RGB(84, 110, 52), leaf2 = RGB(110, 128, 60), leaf3 = RGB(70, 92, 48), trunk = RGB(92, 66, 48),
	lamp = RGB(255, 200, 120),
}
local P = MT.PAL

function MT.ground(o)
	o = o or {}
	T:Clear()
	pcall(function() T.Decoration = false end)   -- the 3D grass blades fill the lens at low camera angles
	T:SetMaterialColor(M.Grass, o.grass or P.grass)
	T:SetMaterialColor(M.Asphalt, o.road or P.road)
	T:SetMaterialColor(M.Rock, RGB(112, 100, 88))
	T:FillBlock(CFrame.new(0, -7, 0), Vector3.new(700, 10, 700), M.Grass)   -- terrain voxels are 4 studs: this puts the surface at y = 0 (a block topped at 0 came out at +2)
	-- the road is a part, not terrain: terrain asphalt reflects the sky like water at low camera angles
	local w = o.roadW or 18
	local r = MT.box("road", { w, 700, 0.3 }, { 0, 0, 0.05 }, o.road or P.road, { mat = M.Asphalt })
	r.Reflectance = 0
end

function MT.hills(o)
	o = o or {}
	local col = o.rock and M.Rock or M.Grass
	local balls = o.balls or {
		{ -120, 260, 70 }, { 20, 300, 90 }, { 150, 270, 75 }, { -240, 150, 80 }, { 240, 120, 85 }, { -90, 380, 110 }, { 110, 400, 105 },
	}
	for _, b in ipairs(balls) do T:FillBall(Vector3.new(b[1], -b[3] * 0.62, -b[2]), b[3], col) end   -- shot (x, y) -> Roblox (x, -, -y)
end

function MT.tree(name, x, y, s)
	s = s or 1
	MT.box(name .. "_trunk", { 0.9 * s, 0.9 * s, 6 * s }, { x, y, 3 * s }, P.trunk, { mat = M.Wood, shape = Enum.PartType.Cylinder, rot = { 0, 0, 90 } })
	local cols = { P.leaf1, P.leaf2, P.leaf3 }
	for i, off in ipairs({ { 0, 0, 7.2 }, { 1.5, 0.6, 6.2 }, { -1.4, -0.5, 6.4 }, { 0.3, 1.2, 8.6 } }) do
		local d = (i == 1 and 5.6 or 4.2) * s
		MT.box(name .. "_leaf" .. i, { d, d, d }, { x + off[1] * s, y + off[2] * s, off[3] * s }, cols[(i % 3) + 1], { mat = M.LeafyGrass, shape = Enum.PartType.Ball })
	end
end

-- a house whose front faces the street (the road runs along shot-y); side = -1 for the left of the road, 1 for the right
function MT.house(name, x, y, o)
	o = o or {}
	local w, d, h = o.w or 12, o.d or 12, o.h or 8
	local side = o.side or 1
	local wall, roof = o.wall or P.cream, o.roof or P.roof
	local mat = o.mat or M.Concrete
	MT.box(name .. "_base", { w + 0.6, d + 0.6, 1.0 }, { x, y, 0.5 }, P.curb, { mat = M.Concrete })
	MT.box(name .. "_wall", { w, d, h }, { x, y, 1 + h / 2 }, wall, { mat = mat })
	local rz = side * 28
	local rw = (w / 2) / math.cos(math.rad(28)) + 0.8
	MT.box(name .. "_roofA", { rw, d + 1.6, 0.6 }, { x - (w / 4) - 0.1, y, 1 + h + w * 0.13 }, roof, { mat = M.Slate, rot = { 0, 0, -28 } })
	MT.box(name .. "_roofB", { rw, d + 1.6, 0.6 }, { x + (w / 4) + 0.1, y, 1 + h + w * 0.13 }, roof, { mat = M.Slate, rot = { 0, 0, 28 } })
	-- front (towards the road) is the side facing x = 0
	local fx = x - side * (w / 2 + 0.05)
	MT.box(name .. "_door", { 0.3, 1.9, 3.6 }, { fx, y - d * 0.18, 1 + 1.8 }, o.door or P.door, { mat = M.Wood })
	for i, wy in ipairs({ y + d * 0.2, y - d * 0.38 }) do
		MT.box(name .. "_frame" .. i, { 0.35, 2.6, 2.9 }, { fx - side * 0.02, wy, 1 + h * 0.55 }, P.trim, { mat = M.Wood })
		MT.box(name .. "_win" .. i, { 0.36, 2.0, 2.2 }, { fx - side * 0.12, wy, 1 + h * 0.55 }, P.lamp, { neon = true, shadow = false })
	end
end

function MT.fence(name, x, y0, y1)
	MT.box(name .. "_rail", { 0.2, math.abs(y1 - y0), 0.25 }, { x, (y0 + y1) / 2, 1.5 }, P.trim, { mat = M.Wood })
	local n = math.floor(math.abs(y1 - y0) / 1.1)
	for i = 0, n do
		MT.box(name .. "_p" .. i, { 0.25, 0.3, 2.2 }, { x, math.min(y0, y1) + i * 1.1, 1.1 }, P.trim, { mat = M.Wood })
	end
end

function MT.lampPost(name, x, y, warm)
	MT.box(name .. "_pole", { 0.4, 0.4, 12 }, { x, y, 6 }, RGB(48, 44, 42), { mat = M.Metal })
	local bulb = MT.box(name .. "_bulb", { 1.3, 1.3, 0.9 }, { x, y, 12.2 }, warm or P.lamp, { neon = true, shadow = false })
	local l = Instance.new("PointLight"); l.Color = warm or P.lamp; l.Range = 18; l.Brightness = 1.2; l.Shadows = true; l.Parent = bulb
end

-- the whole street. o.len, o.roadW, o.crosswalk (default true), o.houses (default true)
function MT.townStreet(o)
	o = o or {}
	local len, roadW = o.len or 160, o.roadW or 18
	MT.ground({ roadW = roadW, grass = o.grass, road = o.road })
	MT.hills(o.hills)
	local cx = roadW / 2
	for _, sd in ipairs({ -1, 1 }) do
		MT.box("walk" .. sd, { 7, len, 0.5 }, { sd * (cx + 3.5), 0, 0.25 }, P.walk, { mat = M.Concrete })
		MT.box("curb" .. sd, { 0.8, len, 0.7 }, { sd * (cx + 0.2), 0, 0.35 }, P.curb, { mat = M.Concrete })
	end
	for y = -len / 2 + 6, len / 2 - 6, 11 do MT.box("dash" .. y, { 0.4, 5, 0.04 }, { 0, y, 0.23 }, P.dash, { shadow = false }) end
	if o.crosswalk ~= false then
		for x = -cx + 1.4, cx - 1.4, 2.6 do MT.box("cw" .. x, { 1.35, 5.2, 0.05 }, { x, 0, 0.24 }, P.stripe, { mat = M.SmoothPlastic, shadow = false }) end
	end
	if o.houses ~= false then
		local cols = { P.brick, P.cream, P.sage, P.slate, P.clay }
		local i = 0
		for _, sd in ipairs({ -1, 1 }) do
			for y = -50, 90, 19 do
				i += 1
				if math.abs(y) > 8 then
					local c = cols[(i % #cols) + 1]
					MT.house("h" .. i, sd * (cx + 7 + 10), y + (i % 3) * 2, { side = sd, wall = c, roof = (i % 2 == 0) and P.roof or P.roof2, mat = (c == P.brick or c == P.clay) and M.Brick or ((c == P.sage or c == P.slate) and M.WoodPlanks or M.Concrete), h = 7 + (i % 3) })
					MT.fence("f" .. i, sd * (cx + 7.5), y - 6, y + 6)
				end
			end
			for y = -40, 100, 17 do MT.tree("t" .. sd .. y, sd * (cx + 5.2), y + 4, 0.9 + ((y // 17) % 3) * 0.15) end
			for y = -44, 96, 24 do if math.abs(y) > 10 then MT.lampPost("lp" .. sd .. y, sd * (cx + 0.9), y) end end
		end
	end
end

return "lib15_world loaded"
