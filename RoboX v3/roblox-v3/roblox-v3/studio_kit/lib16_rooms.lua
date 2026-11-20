-- lib16_rooms (v3.2, 2026-11-20): a lived-in warm interior like the @Gneef houses (Twin Brother, The Watcher's Knot):
-- plank floor, fabric wallpaper with a wood wainscot and trim, a window with curtains and evening light, a bed, a nightstand with a lamp,
-- a rug, a framed picture, a bookshelf, a door. Warm point lights with shadows do the lighting. Load order: after lib15_world.
--   MT.roomV2(o)       the room: o.w (x, default 16), o.d (y, default 18), o.h (default 9), o.wall, o.floor, o.accent colours, o.night (dark window)
--   MT.bedV2(name, x, y, facing)    MT.lampV2(name, x, y, z, col)    MT.rugV2(name, x, y, w, d, c1, c2)    MT.noteProp(name, lines, loc, w, h)
local MT = shared.MT
local RGB = Color3.fromRGB
local M = Enum.Material

MT.ROOMPAL = { wall = RGB(226, 212, 190), wainscot = RGB(124, 78, 48), floor = RGB(138, 86, 52), trim = RGB(244, 236, 218), curtain = RGB(70, 98, 66),
	rug1 = RGB(150, 40, 44), rug2 = RGB(222, 196, 150), blanket = RGB(70, 92, 128), mattress = RGB(240, 232, 216), lamp = RGB(255, 226, 190), wood = RGB(112, 72, 44) }
local P = MT.ROOMPAL

local function light(part, kind, col, bri, range, shadows)
	local l = Instance.new(kind); l.Color = col; l.Brightness = bri; l.Range = range; l.Shadows = shadows ~= false; l.Parent = part; return l
end

function MT.lampV2(name, x, y, z, col)
	col = col or P.lamp
	MT.box(name .. "_base", { 0.9, 0.9, 0.25 }, { x, y, z + 0.12 }, P.wood, { mat = M.Wood })
	MT.box(name .. "_stem", { 0.2, 0.2, 1.1 }, { x, y, z + 0.8 }, RGB(60, 44, 34), { mat = M.Metal })
	local shade = MT.box(name .. "_shade", { 1.5, 1.5, 1.1 }, { x, y, z + 1.7 }, RGB(246, 226, 186), { mat = M.Fabric, shape = Enum.PartType.Cylinder, rot = { 0, 0, 90 } })
	shade.Transparency = 0.15
	local bulb = MT.box(name .. "_bulb", { 0.6, 0.6, 0.6 }, { x, y, z + 1.7 }, col, { neon = true, shadow = false, shape = Enum.PartType.Ball })
	light(bulb, "PointLight", col, 1.15, 26, true)
end

function MT.rugV2(name, x, y, w, d, c1, c2)
	MT.box(name, { w, d, 0.08 }, { x, y, 0.06 }, c1 or P.rug1, { mat = M.Fabric, shadow = false })
	MT.box(name .. "_in", { w - 1.2, d - 1.2, 0.09 }, { x, y, 0.07 }, c2 or P.rug2, { mat = M.Fabric, shadow = false })
	MT.box(name .. "_in2", { w - 2.6, d - 2.6, 0.1 }, { x, y, 0.08 }, c1 or P.rug1, { mat = M.Fabric, shadow = false })
end

-- a bed with its head to the +y wall: wooden frame, mattress, pillow, blanket
function MT.bedV2(name, x, y)
	MT.box(name .. "_frame", { 5, 8, 1.1 }, { x, y, 0.85 }, P.wood, { mat = M.WoodPlanks })
	MT.box(name .. "_head", { 5, 0.5, 3.2 }, { x, y + 4.1, 1.9 }, P.wood, { mat = M.WoodPlanks })
	MT.box(name .. "_mat", { 4.6, 7.4, 0.9 }, { x, y - 0.1, 1.8 }, P.mattress, { mat = M.Fabric })
	MT.box(name .. "_pillow", { 3.2, 1.6, 0.7 }, { x, y + 3, 2.45 }, RGB(250, 246, 236), { mat = M.Fabric })
	MT.box(name .. "_blanket", { 4.8, 5, 0.5 }, { x, y - 1.4, 2.15 }, P.blanket, { mat = M.Fabric })
end

-- a paper note that reads on camera: MT.noteProp("note", { "MY NAME IS THEO.", "MOM IS LYING." }, { x, y, z }, 2.6, 1.8)
function MT.noteProp(name, lines, loc, w, h, rot)
	local board = MT.sign(name, lines, loc, w, h, { bg = "#EDE6D2", rot = rot, colors = { "#3A342E", "#3A342E", "#3A342E", "#3A342E" } })
	board.Material = M.SmoothPlastic; board.Color = RGB(242, 236, 220)
	return board
end

-- Lighting for a room: no sun, a low warm ambient, mostly the lamps. Call after MT.family (MT.roomV2 does it by itself).
MT.INT = MT.INT or { keyB = 2.2, rimB = 1.4, dof = 0.9, amb = RGB(104, 92, 84), bri = 0.25, exp = -0.22, tint = RGB(255, 245, 235), sat = 0.1, con = 0.2, bloom = 0.45, diffuse = 0.12 }
function MT.interiorGrade()
	local L = game:GetService("Lighting"); local I = MT.INT
	L.Ambient = I.amb; L.OutdoorAmbient = I.amb; L.Brightness = I.bri; L.ExposureCompensation = I.exp; L.EnvironmentDiffuseScale = I.diffuse; L.EnvironmentSpecularScale = 0.2
	local cc = L:FindFirstChild("MTColor"); if cc then cc.TintColor = I.tint; cc.Saturation = I.sat; cc.Contrast = I.con end
	local at = L:FindFirstChild("Atmosphere"); if at then at.Density = 0; at.Haze = 0 end
	local b = L:FindFirstChild("Bloom"); if b then b.Intensity = I.bloom end
	MT.famExp = L.ExposureCompensation
	MT.interior = true; MT.dofFar = I.dof
end

function MT.roomV2(o)
	o = o or {}
	local w, d, h = o.w or 16, o.d or 18, o.h or 11
	local wall, floor = o.wall or P.wall, o.floor or P.floor
	-- floor and walls (the front wall, towards the camera at -y, is left open)
	MT.box("floor", { w + 2, d + 8, 0.5 }, { 0, -3, -0.25 }, floor, { mat = M.WoodPlanks })
	MT.box("wallB", { w, 0.6, h }, { 0, d / 2, h / 2 }, wall, { mat = M.SmoothPlastic })
	MT.box("wallL", { 0.6, d, h }, { -w / 2, 0, h / 2 }, wall, { mat = M.SmoothPlastic })
	MT.box("wallR", { 0.6, d, h }, { w / 2, 0, h / 2 }, wall, { mat = M.SmoothPlastic })
	MT.box("ceiling", { w + 2, d + 8, 0.4 }, { 0, -3, h + 0.2 }, RGB(190, 178, 160), { mat = M.SmoothPlastic })
	MT.box("wallF", { w + 2, 0.6, h }, { 0, -d / 2 - 6, h / 2 }, RGB(60, 44, 36), { mat = M.Fabric })   -- behind the camera: keeps the sun out
	MT.box("wallL2", { 0.6, 8, h }, { -w / 2, -d / 2 - 2, h / 2 }, wall, { mat = M.Fabric }); MT.box("wallR2", { 0.6, 8, h }, { w / 2, -d / 2 - 2, h / 2 }, wall, { mat = M.Fabric })
	-- wainscot and trim
	for _, sd in ipairs({ -1, 1 }) do
		MT.box("wains" .. sd, { 0.4, d, 3.2 }, { sd * (w / 2 - 0.45), 0, 1.6 }, P.wainscot, { mat = M.WoodPlanks })
		MT.box("rail" .. sd, { 0.55, d, 0.3 }, { sd * (w / 2 - 0.45), 0, 3.35 }, P.trim, { mat = M.Wood })
		MT.box("base" .. sd, { 0.5, d, 0.45 }, { sd * (w / 2 - 0.45), 0, 0.22 }, P.trim, { mat = M.Wood })
	end
	MT.box("wainsB", { w, 0.4, 3.2 }, { 0, d / 2 - 0.45, 1.6 }, P.wainscot, { mat = M.WoodPlanks })
	MT.box("railB", { w, 0.55, 0.3 }, { 0, d / 2 - 0.45, 3.35 }, P.trim, { mat = M.Wood })
	MT.box("baseB", { w, 0.5, 0.45 }, { 0, d / 2 - 0.45, 0.22 }, P.trim, { mat = M.Wood })
	-- wallpaper: soft vertical stripes above the wainscot, and a few things on the walls (surface detail, like the @Gneef rooms)
	local stripe = RGB(wall.R * 255 - 16, wall.G * 255 - 18, wall.B * 255 - 20)
	for x = -w / 2 + 1, w / 2 - 1, 1.7 do MT.box("st" .. x, { 0.5, 0.04, h - 3.9 }, { x, d / 2 - 0.32, 3.6 + (h - 3.9) / 2 }, stripe, { shadow = false }) end
	for _, sd in ipairs({ -1, 1 }) do for y = -d / 2 + 1, d / 2 - 1, 1.7 do MT.box("sts" .. sd .. y, { 0.04, 0.5, h - 3.9 }, { sd * (w / 2 - 0.32), y, 3.6 + (h - 3.9) / 2 }, stripe, { shadow = false }) end end
	local pastel = { RGB(196, 214, 206), RGB(230, 196, 160), RGB(204, 196, 224), RGB(226, 210, 150) }
	for i = 1, 4 do
		MT.box("post" .. i, { 0.05, 1.5, 1.9 }, { w / 2 - 0.34, -4 + i * 2.1, 6.3 + ((i % 2) * 0.5) }, pastel[i], { shadow = false })
		MT.box("postm" .. i, { 0.06, 0.8, 0.8 }, { w / 2 - 0.36, -4 + i * 2.1, 6.2 + ((i % 2) * 0.5) }, RGB(150 - i * 14, 110, 90), { shadow = false })
	end
	MT.box("clock", { 0.1, 1.5, 1.5 }, { -w / 2 + 0.33, 3, 7.4 }, RGB(246, 240, 226), { mat = M.SmoothPlastic, shape = Enum.PartType.Cylinder, shadow = false })
	-- window in the back wall with curtains and evening light behind it
	local wx = o.windowX or 3.2
	local glow = o.night and RGB(30, 40, 80) or RGB(255, 240, 215)
	MT.box("win_frame", { 4.4, 0.3, 4.6 }, { wx, d / 2 - 0.4, 5.4 }, P.trim, { mat = M.Wood })
	local pane = MT.box("win_pane", { 3.7, 0.2, 3.9 }, { wx, d / 2 - 0.2, 5.4 }, glow, { neon = true, shadow = false })
	light(pane, "PointLight", glow, o.night and 0.5 or 0.7, 24, false)
	MT.box("win_bar_v", { 0.18, 0.25, 3.9 }, { wx, d / 2 - 0.5, 5.4 }, P.trim, { mat = M.Wood }); MT.box("win_bar_h", { 3.7, 0.25, 0.18 }, { wx, d / 2 - 0.5, 5.4 }, P.trim, { mat = M.Wood })
	for _, k in ipairs({ -1, 1 }) do MT.box("curtain" .. k, { 1.3, 0.5, 5.4 }, { wx + k * 2.8, d / 2 - 0.75, 5.2 }, o.curtain or P.curtain, { mat = M.Fabric }) end
	MT.box("rod", { 7.6, 0.2, 0.2 }, { wx, d / 2 - 0.75, 8.1 }, RGB(60, 44, 34), { mat = M.Metal })
	-- picture frame, shelf with books
	MT.box("pic_frame", { 3.0, 0.2, 2.4 }, { -4.2, d / 2 - 0.4, 6 }, P.wood, { mat = M.Wood })
	MT.box("pic", { 2.5, 0.15, 1.9 }, { -4.2, d / 2 - 0.32, 6 }, RGB(196, 176, 120), { mat = M.Fabric })
	MT.box("pic_b", { 1.1, 0.12, 1.1 }, { -4.6, d / 2 - 0.26, 6.1 }, RGB(104, 132, 120), { mat = M.Fabric }); MT.box("pic_c", { 0.9, 0.12, 0.9 }, { -3.7, d / 2 - 0.26, 5.7 }, RGB(226, 150, 80), { mat = M.Fabric })
	-- door on the left wall
	MT.box("door", { 0.35, 3.4, 6.6 }, { -w / 2 + 0.3, -3, 3.3 }, RGB(92, 54, 36), { mat = M.WoodPlanks })
	MT.box("door_frame", { 0.5, 4.0, 7.2 }, { -w / 2 + 0.25, -3, 3.6 }, P.trim, { mat = M.Wood }).Transparency = 0
	MT.box("knob", { 0.3, 0.3, 0.3 }, { -w / 2 + 0.6, -2, 3.4 }, RGB(214, 178, 96), { mat = M.Metal, shape = Enum.PartType.Ball })
	-- furniture
	MT.bedV2("bed", o.bedX or -5.6, d / 2 - 5)
	MT.box("stand", { 2.4, 2, 2.4 }, { -0.4, d / 2 - 1.6, 1.2 }, P.wood, { mat = M.WoodPlanks })
	MT.lampV2("lamp", -0.4, d / 2 - 1.6, 2.4)
	MT.rugV2("rug", 0, -1, 9, 6.5)
	MT.box("shelf", { 3.4, 1.2, 5.4 }, { w / 2 - 2.2, d / 2 - 1.2, 2.7 }, P.wood, { mat = M.WoodPlanks })
	local cols = { RGB(150, 60, 50), RGB(70, 100, 120), RGB(196, 150, 70), RGB(90, 110, 80), RGB(200, 190, 170) }
	for i = 1, 8 do for r = 1, 3 do MT.box("book" .. i .. r, { 0.32, 0.8, 1.1 }, { w / 2 - 3.5 + i * 0.4, d / 2 - 1.15, 0.9 + r * 1.55 }, cols[(i + r) % 5 + 1], { mat = M.Fabric, shadow = false }) end end
	-- warm ceiling-height fill so shadows are soft: one weak lamp near the ceiling
	local fill = MT.box("fill", { 0.5, 0.5, 0.5 }, { 0, -2, h - 3 }, RGB(255, 210, 160), { neon = true, shadow = false }); fill.Transparency = 1
	light(fill, "PointLight", RGB(255, 226, 190), 0.45, 30, true)
	if o.clutter ~= false then MT.clutterV2(w, d) end
	MT.interiorGrade()
end

-- small things that make a room look lived in (the @Gneef rooms are full of them): toy blocks, a ball, slippers, books, a plant, frames
function MT.clutterV2(w, d)
	local cols = { RGB(200, 70, 60), RGB(70, 110, 170), RGB(226, 186, 70), RGB(90, 150, 100) }
	for i = 1, 5 do MT.box("toyb" .. i, { 0.7, 0.7, 0.7 }, { 4.6 + (i % 3) * 0.8, -3.6 - math.floor(i / 3) * 0.9, 0.35 }, cols[(i % 4) + 1], { mat = M.SmoothPlastic, rot = { 0, i * 23, 0 } }) end
	MT.box("toyball", { 0.9, 0.9, 0.9 }, { 3.2, -4.4, 0.45 }, RGB(226, 120, 60), { mat = M.SmoothPlastic, shape = Enum.PartType.Ball })
	MT.box("slip1", { 0.5, 1.0, 0.3 }, { -3.2, 1.2, 0.15 }, RGB(120, 84, 64), { mat = M.Fabric, rot = { 0, 20, 0 } }); MT.box("slip2", { 0.5, 1.0, 0.3 }, { -2.5, 1.4, 0.15 }, RGB(120, 84, 64), { mat = M.Fabric, rot = { 0, -15, 0 } })
	for i = 1, 4 do MT.box("bk" .. i, { 1.4, 1.0, 0.25 }, { -6.6, -2.5, 0.13 + (i - 1) * 0.26 }, cols[i], { mat = M.Fabric, rot = { 0, i * 9, 0 } }) end
	MT.box("pot", { 1.0, 1.0, 1.1 }, { w / 2 - 1.2, -1.8, 0.55 }, RGB(176, 96, 62), { mat = M.Concrete, shape = Enum.PartType.Cylinder, rot = { 0, 0, 90 } })
	for i, off in ipairs({ { 0, 0, 1.8 }, { 0.5, 0.2, 2.3 }, { -0.4, -0.2, 2.2 }, { 0.1, 0.4, 2.8 } }) do MT.box("leaf" .. i, { 1.0, 1.0, 1.0 }, { w / 2 - 1.2 + off[1], -1.8 + off[2], off[3] }, RGB(70 + i * 6, 120, 70), { mat = M.LeafyGrass, shape = Enum.PartType.Ball }) end
	for i = 1, 3 do
		MT.box("lfr" .. i, { 0.1, 1.5, 1.2 }, { -w / 2 + 0.36, -2 - i * 0.5 + i * 1.7, 5.6 + (i % 2) * 0.6 }, RGB(112, 72, 44), { mat = M.Wood, shadow = false })
		MT.box("lpic" .. i, { 0.12, 1.2, 0.9 }, { -w / 2 + 0.38, -2 - i * 0.5 + i * 1.7, 5.6 + (i % 2) * 0.6 }, ({ RGB(190, 206, 190), RGB(226, 200, 160), RGB(200, 190, 214) })[i], { shadow = false })
	end
	MT.box("frame_ns", { 0.9, 0.12, 1.1 }, { 0.3, d / 2 - 1.0, 2.9 }, RGB(112, 72, 44), { mat = M.Wood }); MT.box("pic_ns", { 0.7, 0.1, 0.9 }, { 0.3, d / 2 - 0.94, 2.9 }, RGB(206, 190, 150), { shadow = false })
end

return "lib16_rooms loaded"
