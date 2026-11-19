-- E01 "100 words": look families, the number over every head, camera shake/flash, and the sets.
local MT = shared.MT
local RGB = Color3.fromRGB
local Lighting = game:GetService("Lighting")

---------------------------------------------------------------- look families (look-reference.md §2, on top of MT.look)
local FAM = {
	["mid-neutral-normal"] = { base = "day", sat = 0.34, con = 0.14, bri = 0.02, tint = RGB(255, 251, 244), bloom = 0.3 },
	["mid-warm-vivid"] = { base = "warm", sun = { -0.8, -0.45, 0.38 }, sat = 0.42, con = 0.12, bri = 0.0, tint = RGB(255, 232, 200), bloom = 0.45 },
	["bright-warm-vivid"] = { base = "warm", sun = { -0.6, -0.6, 0.5 }, exp = 0.35, sat = 0.36, con = 0.08, bri = 0.05, tint = RGB(255, 226, 176), bloom = 0.75 },
	["dark-neutral-vivid"] = { base = "night", sat = 0.3, con = 0.14, bri = 0.03, tint = RGB(236, 238, 255), exp = 0.25, bloom = 0.55 },
	["bright-neutral-normal"] = { base = "day", exp = 0.45, sat = -0.05, con = -0.04, bri = 0.12, tint = RGB(255, 255, 255), bloom = 0.95 },
}
function MT.family(name)
	local f = FAM[name]
	MT.look(f.base, f.sun)
	local cc = Lighting:FindFirstChild("MTColor")
	cc.Saturation, cc.Contrast, cc.Brightness, cc.TintColor = f.sat, f.con, f.bri, f.tint
	if f.exp then Lighting.ExposureCompensation = f.exp end
	local b = Lighting:FindFirstChild("Bloom"); if b then b.Intensity = f.bloom end
	MT.famExp = Lighting.ExposureCompensation
end

---------------------------------------------------------------- the rule object: a number over every head
function MT.counter(name, value, o)
	o = o or {}
	local a = MT.actors[name]; if not a then return end
	if not a.counterGui or not a.counterGui.Parent then
		local g = Instance.new("BillboardGui")
		g.Name = "Counter"; g.Size = UDim2.new(1.8, 0, 0.9, 0); g.StudsOffset = Vector3.new(0, 1.65, 0)
		g.LightInfluence = 0; g.AlwaysOnTop = false; g.MaxDistance = 1000
		local f = Instance.new("Frame"); f.Size = UDim2.fromScale(1, 1); f.BackgroundColor3 = RGB(28, 28, 40); f.BackgroundTransparency = 0.12; f.Parent = g
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = f
		local st = Instance.new("UIStroke"); st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = f
		local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(0.86, 0.84); t.Position = UDim2.fromScale(0.07, 0.08)
		t.BackgroundTransparency = 1; t.TextScaled = true; t.Font = Enum.Font.FredokaOne; t.Parent = f
		g.Adornee = a.head; g.Parent = a.head
		a.counterGui, a.counterText, a.counterFrame, a.counterStroke = g, t, f, st
	end
	value = math.max(0, math.floor(value + 0.5))
	a.counterText.Text = tostring(value)
	local col = value == 0 and RGB(240, 70, 50) or (value <= 10 and RGB(255, 168, 40) or RGB(255, 255, 255))
	a.counterStroke.Color = col; a.counterText.TextColor3 = col
	if o.glow then
		a.counterFrame.BackgroundColor3 = RGB(255, 214, 64); a.counterFrame.BackgroundTransparency = 0
		a.counterText.TextColor3 = RGB(60, 36, 8); a.counterStroke.Color = RGB(255, 255, 255)
	else
		a.counterFrame.BackgroundColor3 = RGB(28, 28, 40); a.counterFrame.BackgroundTransparency = 0.12
	end
end
-- count from a to b between frames f0 and f1
function MT.countUp(f, f0, f1, a, b) local p = math.clamp((f - f0) / math.max(1, f1 - f0), 0, 1); return a + (b - a) * (1 - (1 - p) ^ 2) end

---------------------------------------------------------------- camera helpers
-- camOn(name, d, camz, lookz, side, lens, push): camera d studs in front of an actor, heights above its feet
function MT.camOn(name, d, camz, lookz, side, lens, push)
	local a = MT.actors[name]
	local p = a.base.pos
	local f = math.rad(a.base.facing)
	local fwd = Vector3.new(math.sin(f), 0, math.cos(f)); local right = Vector3.new(fwd.Z, 0, -fwd.X)
	local cam = p + fwd * d + right * (side or 0) + Vector3.new(0, camz, 0)
	local look = p + Vector3.new(0, lookz, 0)
	local function back(v) return { v.X, -v.Z, v.Y } end
	return { back(cam), back(look), lens or 30, push = push }
end

local frameEp = MT.frameEpBase or MT.frame
MT.frameEpBase = frameEp
function MT.frame(id, f)
	frameEp(id, f)
	local def = MT.SHOTS[id]
	local cam = workspace.CurrentCamera
	local t = f / 30
	if def.shake then
		local s = type(def.shake) == "function" and def.shake(f) or def.shake
		if s > 0 then
			local rx = s * (math.sin(t * 37.1) + 0.5 * math.sin(t * 91.7))
			local ry = s * (math.cos(t * 29.3) + 0.5 * math.sin(t * 73.1))
			cam.CFrame = cam.CFrame * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(s * 0.6 * math.sin(t * 23.0)))
		end
	end
	if def.flash then Lighting.ExposureCompensation = (MT.famExp or 0) + def.flash(f) end
end

---------------------------------------------------------------- cast
local SKINS = { "#F1C9A5", "#E8B98F", "#D9A57E", "#C98F65", "#A8714D", "#8A5A3C" }
local KHAIR = { "hair_pigtails", "hair_black_short", "hair_floof", "hair_messy_anime", "hair_black_messy", "hair_brown_girl" }
MT.CASTV = {
	jay = { shirt = "shirt_me", pants = "pants_me", hair = "hair_floof", skin = "#E8B98F", face = "neutral" },
	mom = { shirt = "shirt_mom", pants = "pants_mom", hair = "hair_brown_girl", skin = "#E8B98F", face = "smile" },
	grandpa = { shirt = "shirt_dad", pants = "pants_dad", skin = "#E9C3A0", face = "sad" },
	tyler = { shirt = "shirt_c1", pants = "pants_p2", hair = "hair_messy_anime", skin = "#C98F65", face = "laugh" },
	teacher = { shirt = "shirt_teacher", pants = "pants_teacher", hair = "hair_black_short", skin = "#D9A57E", face = "angry" },
	principal = { shirt = "shirt_c7", pants = "pants_p2", hair = "hair_black_messy", skin = "#A8714D", face = "smirk" },
	mayor = { shirt = "shirt_mayor", pants = "pants_mayor", skin = "#E3B58D", face = "smirk" },
}
function MT.kid(i)
	return { shirt = "shirt_c" .. ((i % 9) + 2), pants = "pants_p" .. ((i % 5) + 1), hair = KHAIR[(i % #KHAIR) + 1], skin = SKINS[(i * 5 % 6) + 1], face = "happy" }
end
function MT.cast(name, at, facing, face)
	local base = name:match("^[^#]+")
	local spec = table.clone(MT.CASTV[base] or MT.kid(tonumber(base:match("%d+")) or 1))
	if face then spec.face = face end
	return MT.actor(name, spec, at, facing)
end

---------------------------------------------------------------- sets (shot coords: x right, y away from camera, z up)
local function ground(col, mat) MT.box("ground", { 700, 700, 1 }, { 0, 0, -0.5 }, col or "#86C66F", { mat = mat or Enum.Material.Grass }) end

function MT.setStreet()
	ground()
	MT.box("walk", { 700, 7, 0.2 }, { 0, 3, 0.1 }, "#E4DED2", { mat = Enum.Material.Concrete })
	MT.box("road", { 700, 14, 0.12 }, { 0, 13.5, 0.06 }, "#4F5563", { mat = Enum.Material.Asphalt })
	MT.box("line", { 700, 0.35, 0.14 }, { 0, 13.5, 0.08 }, "#F5D34F")
	MT.box("walk2", { 700, 6, 0.2 }, { 0, 23.5, 0.1 }, "#E4DED2", { mat = Enum.Material.Concrete })
	MT.put("house_ca", { -38, 48, 0 }, { height = 22, rot = 180 })
	MT.put("house_cute", { 40, 46, 0 }, { height = 19, rot = 180 })
	MT.put("tree_cartoon", { -16, 33, 0 }, { height = 15 })
	MT.put("tree_cartoon", { 30, 30, 0 }, { height = 12, rot = 70 })
	MT.put("townhall", { -4, 150, 0 }, { height = 46, rot = 180 })
	-- bakery
	MT.box("bak_wall", { 15, 8, 10 }, { 12, 31, 5 }, "#F7B7A3")
	MT.box("bak_roof", { 16, 9, 0.8 }, { 12, 31, 10.2 }, "#B94A2C")
	MT.box("bak_awn", { 15.4, 2.4, 0.5 }, { 12, 25.9, 7.2 }, "#E8452C", { rot = { -14, 0, 0 } })
	MT.box("bak_win", { 9, 0.3, 4.2 }, { 12, 26.85, 3.6 }, "#BFE3F5", { refl = 0.2 })
	MT.box("bak_door", { 2.8, 0.3, 5.2 }, { 5.6, 26.85, 2.6 }, "#7A4A28")
	MT.sign("bak_sign", { "BAKERY" }, { 12, 26.7, 9.1 }, 9, 1.6, { bg = "#FFF4D6", colors = { "#B94A2C" } })
	MT.sign("bak_cards", { "YES $2", "NO $2" }, { 13, 26.6, 3.5 }, 6.4, 3.6, { bg = "#FFFFFF", border = "#F5D34F", colors = { "#24A148", "#E8452C" }, sizes = { 0.4, 0.4 } })
	-- the rule billboard
	MT.box("bb_post1", { 0.5, 0.5, 8 }, { -12.5, 26, 4 }, "#3A3F4A"); MT.box("bb_post2", { 0.5, 0.5, 8 }, { -1.5, 26, 4 }, "#3A3F4A")
	MT.sign("rule", { "WELCOME TO PIPPIN", "100 WORDS A DAY" }, { -7, 25.7, 8.6 }, 13, 4.2,
		{ bg = "#FFF8E7", border = "#2F3E63", colors = { "#2F3E63", "#E8452C" }, sizes = { 0.3, 0.44 } })
	for i, x in ipairs({ -30, -20, 20, 32 }) do
		MT.box("lamp" .. i, { 0.35, 0.35, 9 }, { x, 6.8, 4.5 }, "#3A3F4A")
		MT.box("lampHead" .. i, { 1.2, 1.2, 0.7 }, { x, 6.8, 9.2 }, "#FFF2C4", { neon = true })
	end
end

function MT.setKitchen()
	ground("#C99A6B", Enum.Material.WoodPlanks)
	MT.box("wall", { 44, 1, 14 }, { 0, 12, 7 }, "#F6E3BE")
	MT.box("wallL", { 1, 30, 14 }, { -16, 0, 7 }, "#F6E3BE")
	MT.box("win", { 8, 0.3, 5 }, { -5, 11.4, 7.5 }, "#A9DBF7", { neon = true, tr = 0.1 })
	MT.box("winFrame", { 8.8, 0.25, 0.5 }, { -5, 11.35, 7.5 }, "#FFFFFF")
	MT.box("counter", { 14, 3, 3.2 }, { 7, 9.8, 1.6 }, "#FAFAF7")
	MT.box("top", { 14.4, 3.4, 0.3 }, { 7, 9.8, 3.3 }, "#3A3F4A")
	MT.box("tiles", { 14, 0.2, 4 }, { 7, 11.4, 5.5 }, "#8FC9F0", { mat = Enum.Material.Glass })
	MT.box("fridge", { 4, 3, 8 }, { -12, 9.6, 4 }, "#E6EEF2")
	MT.sign("note", { "SAVE YOUR", "WORDS!" }, { -12, 8.0, 5.6 }, 2.8, 1.9, { bg = "#FFF59A", colors = { "#E8452C", "#E8452C" } })
	MT.box("pot", { 1.4, 1.4, 1 }, { 9, 9.8, 4 }, "#E8452C")
	MT.box("bowl", { 1.2, 1.2, 0.4 }, { 3, 9.8, 3.65 }, "#F5D66E")
	local l = MT.box("ceil", { 2, 2, 0.3 }, { 0, 5, 13 }, "#FFF2C4", { neon = true })
	MT.light(l, "PointLight", "#FFE2B0", 1.6, 30)
end

function MT.setClass()
	ground("#B98A5E", Enum.Material.WoodPlanks)
	MT.box("wall", { 50, 1, 14 }, { 0, 14, 7 }, "#CFE8D8")
	MT.box("wallL", { 1, 34, 14 }, { -18, 0, 7 }, "#CFE8D8")
	MT.box("board", { 16, 0.4, 6 }, { 2, 13.4, 7.4 }, "#2C5E4A")
	MT.sign("boardText", { "QUIET CLASS", "SAVE YOUR WORDS" }, { 2, 13.15, 7.4 }, 15, 5.4, { bg = "#2C5E4A", colors = { "#FFFFFF", "#F5D66E" }, sizes = { 0.32, 0.32 } })
	MT.box("clock", { 1.8, 0.3, 1.8 }, { 14, 13.4, 10.5 }, "#FFFFFF")
	MT.box("bellPost", { 0.4, 0.4, 7 }, { -14, 10, 3.5 }, "#6B5B4A")
	MT.bell = MT.box("bell", { 1.6, 1.6, 1.4 }, { -14, 9.6, 7.4 }, "#F2C230", { mat = Enum.Material.Metal, shape = Enum.PartType.Ball })
	for r = 0, 1 do for c = -1, 1 do
		local x, y = c * 7 + 2, 2 + r * 5
		MT.box(("desk%d%d"):format(r, c), { 3.2, 1.8, 0.25 }, { x, y - 1.7, 2.45 }, "#F5D66E")
		MT.box(("deskL%d%d"):format(r, c), { 3, 1.6, 2.3 }, { x, y - 1.7, 1.15 }, "#D9A64B")
	end end
	local l = MT.box("ceil", { 3, 3, 0.3 }, { 0, 4, 13.6 }, "#FFFFFF", { neon = true })
	MT.light(l, "PointLight", "#FFF6E0", 1.4, 34)
end

-- Grandpa's porch. night = porch light on, summer = golden flowers
function MT.setPorch(o)
	o = o or {}
	ground()
	MT.box("path", { 3.2, 18, 0.15 }, { 0, -2, 0.08 }, "#E4DED2", { mat = Enum.Material.Concrete })
	MT.box("houseWall", { 28, 1, 15 }, { 0, 13, 7.5 }, "#8FC1E8", { mat = Enum.Material.WoodPlanks })
	MT.box("roof", { 30, 12, 1 }, { 0, 10, 15.2 }, "#7A4A28", { rot = { 10, 0, 0 } })
	MT.box("door", { 3.4, 0.4, 6.4 }, { 0, 12.4, 4.2 }, "#B94A2C")
	MT.box("winL", { 4.6, 0.3, 3.6 }, { -7, 12.4, 6 }, "#FFF2C4", { neon = o.night })
	MT.box("winR", { 4.6, 0.3, 3.6 }, { 7, 12.4, 6 }, "#FFF2C4", { neon = o.night })
	if not o.night then MT.box("winL", { 4.6, 0.3, 3.6 }, { -7, 12.35, 6 }, "#A9DBF7") ; MT.box("winR", { 4.6, 0.3, 3.6 }, { 7, 12.35, 6 }, "#A9DBF7") end
	MT.box("deck", { 18, 6, 1 }, { 0, 9.5, 0.5 }, "#C99A6B", { mat = Enum.Material.WoodPlanks })
	MT.box("step1", { 4.4, 1.4, 0.5 }, { 0, 5.8, 0.25 }, "#B98A5E", { mat = Enum.Material.WoodPlanks })
	for i, x in ipairs({ -8.6, 8.6 }) do MT.box("post" .. i, { 0.5, 0.5, 8 }, { x, 6.8, 5 }, "#FAFAF7") end
	MT.box("rail1", { 6, 0.3, 0.3 }, { -5.6, 6.8, 3 }, "#FAFAF7"); MT.box("rail2", { 6, 0.3, 0.3 }, { 5.6, 6.8, 3 }, "#FAFAF7")
	MT.box("mailbox", { 0.8, 1.4, 0.9 }, { 5, -2, 3.5 }, "#E8452C"); MT.box("mailPost", { 0.3, 0.3, 3 }, { 5, -2, 1.5 }, "#6B5B4A")
	MT.sign("mailName", { "GRANDPA JOE" }, { 5, -2.75, 3.5 }, 1.3, 0.5, { bg = "#FFFFFF", colors = { "#3A3F4A" } })
	MT.put("house_ca", { -36, 26, 0 }, { height = 20, rot = 180 })
	MT.put("tree_cartoon", { 18, 16, 0 }, { height = 15 })
	MT.put("tree_cartoon", { -17, 4, 0 }, { height = 11, rot = 120 })
	if o.summer then
		for i = 1, 14 do MT.box("flower" .. i, { 0.6, 0.6, 0.6 }, { -9 + (i * 1.37) % 18, 5 + (i * 0.7) % 1.5, 0.3 }, i % 2 == 0 and "#F6A6C1" or "#F5D66E") end
	end
	if o.night then
		local l = MT.box("porchLamp", { 0.8, 0.8, 1 }, { -3, 12.2, 8 }, "#FFE2A0", { neon = true })
		MT.light(l, "PointLight", "#FFD08A", 2.4, 22)
	end
	if o.notice then
		MT.sign("notice", { "TOWN HALL", "NOTICE" }, { 0, 12.15, 4.6 }, 2.6, 1.8, { bg = "#FFFFFF", border = "#E8452C", colors = { "#3A3F4A", "#E8452C" } })
	end
end

function MT.setTownHall()
	ground("#E4DED2", Enum.Material.Concrete)
	MT.put("townhall", { 0, 64, 0 }, { height = 32, rot = 180 })
	MT.box("steps", { 26, 6, 1.2 }, { 0, 26, 0.6 }, "#D6D2C8", { mat = Enum.Material.Concrete })
	MT.box("bannerPost1", { 0.4, 0.4, 7 }, { -6.2, 9, 3.5 }, "#3A3F4A"); MT.box("bannerPost2", { 0.4, 0.4, 7 }, { 6.2, 9, 3.5 }, "#3A3F4A")
	MT.sign("banner", { "WORDS ARE", "FOR THE YOUNG" }, { 0, 8.8, 8.9 }, 12, 3.2, { bg = "#2F3E63", border = "#F5D34F", colors = { "#FFFFFF", "#F5D34F" }, sizes = { 0.36, 0.36 } })
	MT.put("tree_cartoon", { -20, 22, 0 }, { height = 13 })
	MT.put("tree_cartoon", { 20, 22, 0 }, { height = 13, rot = 90 })
end

return "set E01 loaded"
