-- ep07-knock SET: the warm house room (lib16_rooms) with a small door low in the back wall, glowing at the gap
local MT = shared.MT
local RGB = Color3.fromRGB
local function house()
	MT.family("mid-warm-vivid"); MT.roomV2({})
	MT.box("tiny_frame", { 1.3, 0.2, 1.9 }, { -2.4, 8.5, 1.1 }, RGB(244, 236, 218), { mat = Enum.Material.Wood })
	MT.box("tiny_door", { 1.0, 0.2, 1.6 }, { -2.4, 8.42, 1.0 }, RGB(88, 52, 36), { mat = Enum.Material.WoodPlanks })
	local g = MT.box("tiny_glow", { 1.0, 0.1, 0.12 }, { -2.4, 8.3, 0.24 }, RGB(255, 190, 110), { neon = true, shadow = false })
	local l = Instance.new("PointLight"); l.Color = RGB(255, 190, 110); l.Brightness = 1.2; l.Range = 9; l.Shadows = false; l.Parent = g
	MT.box("tiny_knob", { 0.14, 0.14, 0.14 }, { -2.0, 8.3, 1.0 }, RGB(214, 178, 96), { mat = Enum.Material.Metal, shape = Enum.PartType.Ball })
end
MT.house = house
MT.setPreview("house", house, { cast = { { "hero", { 1.5, 0 }, 0, "worried" } },
	cams = { wide = { { 0, -10.5, 4.2 }, { 0, 5, 4.2 }, 44 }, low = { { -4.8, -3, 1.4 }, { -2.4, 8.4, 1.2 }, 36 }, top = { { 6.5, -8.5, 9.8 }, { -1, 4, 1.5 }, 52 } } })
return "sets"
