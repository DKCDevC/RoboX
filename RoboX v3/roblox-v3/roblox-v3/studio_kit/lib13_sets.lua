-- lib13_sets: Cinematic Set Dressing & Style Unifier for RoboX v3 (auto-loaded by load.py after lib12).
-- Solves inconsistent free Creator Store models and empty backgrounds with 1-line cinematic set builders:
--   MT.unifyModel(model, opts)          -- strips scripts/fx, kills shiny plastic reflectance, unifies material style
--   MT.streetKit(len, width, opts)      -- asphalt road, dashed stripes, raised sidewalks, glowing streetlamps
--   MT.horizon(radius, color, count)    -- distant layered mountains so low-angle shots never show an empty map edge
--   MT.roomKit(w, d, h, opts)           -- complete interior room (wood floor, baseboards, window light, rug, warm lamp)
--   MT.heroLight(name, col, range, bri) -- soft warm key/rim light attached to an actor so faces pop in dark scenes
local MT = shared.MT
local RGB = Color3.fromRGB

local function makePart(parent, name, size, cf, color, mat, opts)
	opts = opts or {}
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = type(color) == "string" and MT.C(color) or color
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = opts.collide ~= false
	p.CanQuery = opts.query ~= false
	p.CastShadow = opts.shadow ~= false
	p.Reflectance = opts.reflectance or 0
	p.Transparency = opts.transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- 1. Unify any free Creator Store model to match the clean RoboX v3 cinematic look
function MT.unifyModel(model, opts)
	opts = opts or {}
	if not model then return end
	local keepMat = opts.keepMaterial == true
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ProximityPrompt")
			or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = true
			d.Reflectance = 0
			if not keepMat and d.Material == Enum.Material.Plastic then
				d.Material = Enum.Material.SmoothPlastic
			end
			if d.Size.Magnitude < 2.2 then d.CastShadow = false end
			if opts.tint then
				d.Color = d.Color:Lerp(type(opts.tint) == "string" and MT.C(opts.tint) or opts.tint, opts.tintStrength or 0.15)
			end
		end
	end
	return model
end

-- 2. Cinematic street kit centered at origin (or opts.origin = {x, y, z}), running along Z (shot Y axis)
function MT.streetKit(len, width, opts)
	opts = opts or {}
	len = len or 180
	width = width or 22
	local origin = opts.origin and MT.V(opts.origin[1], opts.origin[2], opts.origin[3] or 0) or Vector3.new(0, 0, 0)
	local folder = Instance.new("Model")
	folder.Name = opts.name or "MTStreetKit"
	folder.Parent = MT.root()

	-- Asphalt road
	makePart(folder, "Road", Vector3.new(width, 0.5, len), CFrame.new(origin + Vector3.new(0, -0.25, 0)), RGB(46, 48, 54), Enum.Material.Asphalt)

	-- Center dashed yellow lines
	for z = -len / 2 + 6, len / 2 - 6, 12 do
		makePart(folder, "Dash", Vector3.new(0.45, 0.05, 5.5), CFrame.new(origin + Vector3.new(0, 0.02, z)), RGB(242, 198, 64), Enum.Material.SmoothPlastic, { shadow = false, collide = false })
	end

	-- Raised sidewalks & curbs on both sides
	local swW = opts.sidewalkWidth or 9
	for _, side in ipairs({ -1, 1 }) do
		local sx = side * (width / 2 + swW / 2)
		makePart(folder, "Sidewalk", Vector3.new(swW, 0.45, len), CFrame.new(origin + Vector3.new(sx, 0.225, 0)), RGB(188, 184, 176), Enum.Material.Concrete)
		local cx = side * (width / 2 + 0.35)
		makePart(folder, "Curb", Vector3.new(0.7, 0.52, len), CFrame.new(origin + Vector3.new(cx, 0.26, 0)), RGB(152, 148, 142), Enum.Material.Concrete)

		-- Streetlamps with warm glowing bulbs
		local lampStep = opts.lampStep or 32
		local lit = opts.night == true
		for z = -len / 2 + 14, len / 2 - 14, lampStep do
			local lx = side * (width / 2 + 1.4)
			makePart(folder, "LampPole", Vector3.new(0.45, 13.5, 0.45), CFrame.new(origin + Vector3.new(lx, 7.2, z)), RGB(44, 48, 56), Enum.Material.Metal)
			makePart(folder, "LampArm", Vector3.new(3.2, 0.35, 0.35), CFrame.new(origin + Vector3.new(lx - side * 1.4, 13.8, z)), RGB(44, 48, 56), Enum.Material.Metal)
			local bulb = makePart(
				folder, "LampBulb", Vector3.new(1.1, 0.45, 0.8),
				CFrame.new(origin + Vector3.new(lx - side * 2.6, 13.5, z)),
				lit and RGB(255, 224, 150) or RGB(230, 232, 235),
				lit and Enum.Material.Neon or Enum.Material.SmoothPlastic,
				{ shadow = false }
			)
			if lit then
				local pl = Instance.new("PointLight")
				pl.Color = RGB(255, 210, 135)
				pl.Brightness = opts.lampBright or 2.2
				pl.Range = opts.lampRange or 34
				pl.Shadows = true
				pl.Parent = bulb
			end
		end
	end
	return folder
end

-- 3. Distant mountain ring around the horizon so low-angle shots always have cinematic depth
function MT.horizon(radius, color, count)
	radius = radius or 240
	count = count or 18
	local col = color and (type(color) == "string" and MT.C(color) or color) or RGB(94, 118, 148)
	local folder = Instance.new("Model")
	folder.Name = "MTHorizon"
	folder.Parent = MT.root()
	for i = 1, count do
		local ang = (i / count) * math.pi * 2
		local h = 48 + ((i * 37) % 45)
		local w = 55 + ((i * 23) % 40)
		local d = 35 + ((i * 19) % 25)
		local x = math.cos(ang) * radius
		local z = math.sin(ang) * radius
		local p = makePart(
			folder, "Peak_" .. i, Vector3.new(w, h, d),
			CFrame.new(x, h * 0.35, z) * CFrame.Angles(0, -ang + 0.3, math.rad(((i % 3) - 1) * 14)),
			col:Lerp(RGB(140, 165, 195), (i % 4) * 0.08),
			Enum.Material.Slate,
			{ shadow = false, collide = false, query = false }
		)
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Wedge
		mesh.Parent = p
	end
	return folder
end

-- 4. Complete interior room kit (wood floor, walls, baseboards, glowing window, rug, warm ceiling light)
function MT.roomKit(w, d, h, opts)
	opts = opts or {}
	w, d, h = w or 26, d or 22, h or 12
	local origin = opts.origin and MT.V(opts.origin[1], opts.origin[2], opts.origin[3] or 0) or Vector3.new(0, 0, 0)
	local wallCol = opts.wallColor or RGB(236, 228, 214)
	local floorCol = opts.floorColor or RGB(158, 114, 76)
	local rugCol = opts.rugColor or RGB(76, 114, 148)
	local folder = Instance.new("Model")
	folder.Name = opts.name or "MTRoomKit"
	folder.Parent = MT.root()

	-- Floor & ceiling
	makePart(folder, "Floor", Vector3.new(w, 0.5, d), CFrame.new(origin + Vector3.new(0, -0.25, 0)), floorCol, Enum.Material.WoodPlanks)
	if opts.ceiling ~= false then
		makePart(folder, "Ceiling", Vector3.new(w, 0.5, d), CFrame.new(origin + Vector3.new(0, h + 0.25, 0)), RGB(246, 244, 240), Enum.Material.SmoothPlastic)
	end

	-- Back, Left, Right walls (front wall omitted by default so cameras have clear sightlines)
	makePart(folder, "WallBack", Vector3.new(w, h, 0.6), CFrame.new(origin + Vector3.new(0, h / 2, -d / 2)), wallCol, Enum.Material.SmoothPlastic)
	makePart(folder, "WallLeft", Vector3.new(0.6, h, d), CFrame.new(origin + Vector3.new(-w / 2, h / 2, 0)), wallCol, Enum.Material.SmoothPlastic)
	makePart(folder, "WallRight", Vector3.new(0.6, h, d), CFrame.new(origin + Vector3.new(w / 2, h / 2, 0)), wallCol, Enum.Material.SmoothPlastic)

	-- Baseboards (adds immediate realism)
	makePart(folder, "TrimBack", Vector3.new(w, 0.7, 0.75), CFrame.new(origin + Vector3.new(0, 0.35, -d / 2 + 0.08)), RGB(248, 246, 242), Enum.Material.SmoothPlastic)
	makePart(folder, "TrimLeft", Vector3.new(0.75, 0.7, d), CFrame.new(origin + Vector3.new(-w / 2 + 0.08, 0.35, 0)), RGB(248, 246, 242), Enum.Material.SmoothPlastic)
	makePart(folder, "TrimRight", Vector3.new(0.75, 0.7, d), CFrame.new(origin + Vector3.new(w / 2 - 0.08, 0.35, 0)), RGB(248, 246, 242), Enum.Material.SmoothPlastic)

	-- Center fabric rug
	makePart(folder, "Rug", Vector3.new(w * 0.52, 0.08, d * 0.48), CFrame.new(origin + Vector3.new(0, 0.04, 0.5)), rugCol, Enum.Material.Fabric, { shadow = false })

	-- Back wall framed glowing window
	local winCol = opts.night and RGB(110, 148, 210) or RGB(215, 240, 255)
	makePart(folder, "WindowFrame", Vector3.new(6.8, 5.2, 0.25), CFrame.new(origin + Vector3.new(0, h * 0.56, -d / 2 + 0.35)), RGB(248, 246, 242), Enum.Material.Wood)
	makePart(folder, "WindowGlass", Vector3.new(6.0, 4.4, 0.3), CFrame.new(origin + Vector3.new(0, h * 0.56, -d / 2 + 0.38)), winCol, Enum.Material.Neon, { shadow = false })

	-- Warm ceiling lamp
	local lamp = makePart(folder, "CeilingLamp", Vector3.new(2.2, 0.35, 2.2), CFrame.new(origin + Vector3.new(0, h - 0.2, 0)), RGB(255, 236, 195), Enum.Material.Neon, { shadow = false })
	local pl = Instance.new("PointLight")
	pl.Color = opts.lampColor or RGB(255, 224, 178)
	pl.Brightness = opts.lampBright or (opts.night and 1.8 or 1.1)
	pl.Range = math.max(w, d) * 1.4
	pl.Shadows = true
	pl.Parent = lamp
	return folder
end

-- 5. Soft warm key/rim light attached to an actor so their face pops in dark or backlit shots
function MT.heroLight(name, col, range, bright)
	local a = MT.actors[name]; if not a or not a.head then return end
	local old = a.head:FindFirstChild("MTHeroLight")
	if old then old:Destroy() end
	local pl = Instance.new("PointLight")
	pl.Name = "MTHeroLight"
	pl.Color = col and (type(col) == "string" and MT.C(col) or col) or RGB(255, 232, 200)
	pl.Range = range or 12
	pl.Brightness = bright or 1.2
	pl.Shadows = false
	pl.Parent = a.head
	return pl
end

return "lib13_sets loaded (unifyModel + streetKit + horizon + roomKit + heroLight)"
