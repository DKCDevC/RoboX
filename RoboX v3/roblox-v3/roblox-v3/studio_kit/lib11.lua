-- lib11: episode helpers, lifted from E01 "100 words" (2026-11-19) so an episode only writes its sets and shots.
-- Load after lib10 (load.py does). load.py also sets shared.MT.N[id] = frame count from shots.json before the episode's lua.
--
--   MT.family(name)                    one of the 6 look families (look-reference.md §2), applied on top of MT.look
--   MT.counter(name, value, o)         a number in a pill over an actor's head (the "rule object" of a number-rule episode)
--   MT.countUp(f, f0, f1, a, b)        ease a value from a to b between frames f0 and f1
--   MT.camOn(name, d, camz, lookz, side, lens, push)   camera d studs in front of an actor (heights above its feet)
--   def.shake = n | fn(f), def.flash = fn(f)           per-shot camera shake (degrees) and exposure flash
--   MT.castPreview(names, faces), MT.setPreview(name, buildFn, opts), MT.preview(id, buildFn)   one-frame cast / set sheet shots (stage_capture.py)
--   def.roll = deg | fn(f), MT.rollRamp(f, f0, f1, a, b)   Dutch tilt (about 3-8 degrees over a shot); UNTESTED in Studio, check it on the check sheet first
--   MT.drop(f, f0, z0, z1, len, bounce)                height of a dropped prop: gravity fall, then one small bounce
--   MT.CASTV[name] = spec; MT.cast(name, at, facing, face)  named cast; any other name ending in a number is a crowd kid
--   MT.around(cx, cy, r, k, i0, faceAt), MT.chatter(list, f, face)   a ring of kids, and everyone in a list talking
--   MT.resetShots(); MT.shot(id, def)  register shots in order (idx and n are filled in)
local MT = shared.MT
local RGB = Color3.fromRGB
local Lighting = game:GetService("Lighting")

---------------------------------------------------------------- look families (starting values from E01; tune per episode)
MT.FAM = {
	["mid-neutral-normal"] = { base = "day", sat = 0.34, con = 0.14, bri = 0.02, tint = RGB(255, 251, 244), bloom = 0.3 },
	["mid-warm-vivid"] = { base = "warm", sun = { -0.8, -0.45, 0.38 }, sat = 0.42, con = 0.12, bri = 0.0, tint = RGB(255, 232, 200), bloom = 0.45 },
	["bright-warm-vivid"] = { base = "warm", sun = { -0.6, -0.6, 0.5 }, exp = 0.35, sat = 0.36, con = 0.08, bri = 0.05, tint = RGB(255, 226, 176), bloom = 0.75 },
	-- Night: E01's faces went purple (tint 190,205,255, then 236,238,255 + exposure 0.25 was still too cool on skin). Keep the
	-- tint nearly neutral, let the "night" sky and ambient carry the blue, and light faces with MT.faceLight (warm).
	["dark-neutral-vivid"] = { base = "night", sat = 0.3, con = 0.14, bri = 0.04, tint = RGB(244, 244, 255), exp = 0.35, bloom = 0.55 },
	["dark-warm-vivid"] = { base = "night", sat = 0.45, con = 0.16, bri = 0.0, tint = RGB(255, 210, 180), exp = 0.1, bloom = 0.7 },
	["bright-neutral-normal"] = { base = "day", exp = 0.45, sat = -0.05, con = -0.04, bri = 0.12, tint = RGB(255, 255, 255), bloom = 0.95 },
}
function MT.family(name)
	local f = MT.FAM[name] or error("lib11: unknown look family " .. tostring(name))
	MT.look(f.base, f.sun)
	local cc = Lighting:FindFirstChild("MTColor")
	cc.Saturation, cc.Contrast, cc.Brightness, cc.TintColor = f.sat, f.con, f.bri, f.tint
	if f.exp then Lighting.ExposureCompensation = f.exp end
	local b = Lighting:FindFirstChild("Bloom"); if b then b.Intensity = f.bloom end
	MT.famExp = Lighting.ExposureCompensation
end

---------------------------------------------------------------- a number over a head
-- Size in studs: E01's first 2.5 x 1.25 covered faces in close-ups; 1.8 x 0.9, 1.65 above the head centre reads well.
-- E01 review: still a little big in close-ups at 1.8 x 0.9; 1.5 x 0.75 keeps it readable in wides.
MT.COUNTER = MT.COUNTER or { w = 1.5, h = 0.75, up = 1.55 }
function MT.counter(name, value, o)
	o = o or {}
	local a = MT.actors[name]; if not a then return end
	if not a.counterGui or not a.counterGui.Parent then
		local C = MT.COUNTER
		local g = Instance.new("BillboardGui")
		g.Name = "Counter"; g.Size = UDim2.new(C.w, 0, C.h, 0); g.StudsOffset = Vector3.new(0, C.up, 0)
		g.LightInfluence = 0; g.AlwaysOnTop = false; g.MaxDistance = 1000
		local f = Instance.new("Frame"); f.Size = UDim2.fromScale(1, 1); f.BackgroundColor3 = RGB(28, 28, 40); f.BackgroundTransparency = 0.12; f.Parent = g
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = f
		local st = Instance.new("UIStroke"); st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = f
		local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(0.86, 0.84); t.Position = UDim2.fromScale(0.07, 0.08)
		t.BackgroundTransparency = 1; t.TextScaled = true; t.Font = Enum.Font.FredokaOne; t.Parent = f
		g.Adornee = a.head; g.Parent = a.head
		a.counterGui, a.counterText, a.counterFrame, a.counterStroke = g, t, f, st
	end
	local text = type(value) == "number" and tostring(math.max(0, math.floor(value + 0.5))) or tostring(value)
	a.counterText.Text = text
	local n = tonumber(text) or 100
	local col = o.color or (n == 0 and RGB(240, 70, 50) or (n <= 10 and RGB(255, 168, 40) or RGB(255, 255, 255)))
	a.counterStroke.Color = col; a.counterText.TextColor3 = col
	if o.glow then
		a.counterFrame.BackgroundColor3 = RGB(255, 214, 64); a.counterFrame.BackgroundTransparency = 0
		a.counterText.TextColor3 = RGB(60, 36, 8); a.counterStroke.Color = RGB(255, 255, 255)
	else
		a.counterFrame.BackgroundColor3 = RGB(28, 28, 40); a.counterFrame.BackgroundTransparency = 0.12
	end
end
function MT.countUp(f, f0, f1, a, b) local p = math.clamp((f - f0) / math.max(1, f1 - f0), 0, 1); return a + (b - a) * (1 - (1 - p) ^ 2) end

---------------------------------------------------------------- art grade (v3.2, 2026-11-20: from the @Gneef frames, gneef-study.md section 10)
-- The kit's looks blew the colours up (ColorCorrection saturation +0.34..0.57 on top of pure-primary part colours), filled the
-- shadows with a blue ambient and lit everything with a flat high sun. The art grade runs after MT.family and pulls that back:
-- deeper, warmer shadows, a lower and warmer sun, a modest saturation, a warm tint, shallow depth of field.
-- Tune at run time: shared.MT.ART.ambK = 0.4 (then rebuild the shot). MT.ART.on = false gives the old look.
MT.ART = MT.ART or {}
local ART0 = {
	on = true,
	ambK = 0.7, ambWarm = 0.6,          -- ambient / outdoor ambient brightness scale, and how far to pull the blue toward a warm grey
	nightAmbK = 0.85,                   -- night scenes keep more of their blue fill
	briMul = 1.25, expAdd = -0.3,       -- key light brightness scale, exposure offset
	shadowSoft = 0.3, spec = 0.2, diffuse = 0.45,   -- environment lighting is mostly the blue sky: keep it low so shadows stay warm
	sat = 0.2, nightSat = 0.14, con = 0.24,
	tint = Color3.fromRGB(255, 222, 188), nightTint = Color3.fromRGB(240, 226, 255),
	-- day = golden hour: a low sun behind the scene (shot +y is where most cameras look), warm haze, orange Decay tints the sky
	sunDir = { 0.25, 0.9, 0.2 }, sunZ = 0.55,
	atmoDensity = 0.42, atmoWarm = 0.8, atmoColor = Color3.fromRGB(255, 190, 140), atmoDecay = Color3.fromRGB(225, 110, 60), decayMix = 1.0,
	atmoHaze = 2.3, atmoOffset = 0.15, glare = 0.5,
	nightAtmoColor = Color3.fromRGB(120, 90, 150), nightAtmoDecay = Color3.fromRGB(70, 55, 120), nightHaze = 1.6, nightDensity = 0.38,
	keyB = 0.9, rimB = 0.9,             -- portrait light strengths
	dofFar = 0.4,
	bloomMul = 1.0,
}
for k, v in pairs(ART0) do if MT.ART[k] == nil then MT.ART[k] = v end end
function MT.artReset() MT.ART = {}; for k, v in pairs(ART0) do MT.ART[k] = v end end
local function warmGrey(l) return Color3.new(math.clamp(l * 1.1, 0, 1), math.clamp(l * 0.98, 0, 1), math.clamp(l * 0.84, 0, 1)) end
local function scaleWarm(c, k, mix)
	local l = (c.R * 0.3 + c.G * 0.59 + c.B * 0.11) * k
	return Color3.new(c.R * k, c.G * k, c.B * k):Lerp(warmGrey(l), mix)
end
function MT.artGrade(name)
	local A = MT.ART
	MT.interior = false
	local f = MT.FAM[name]; local night = f and f.base == "night"
	if night then
		Lighting.GeographicLatitude = 35; Lighting.ClockTime = A.nightClock or 18.7   -- just after sunset: a purple-blue sky instead of black
		Lighting.Ambient = scaleWarm(Lighting.Ambient, A.nightAmbK, 0.15)
		Lighting.OutdoorAmbient = scaleWarm(Lighting.OutdoorAmbient, A.nightAmbK, 0.15)
	else
		Lighting.Ambient = scaleWarm(Lighting.Ambient, A.ambK, A.ambWarm)
		Lighting.OutdoorAmbient = scaleWarm(Lighting.OutdoorAmbient, A.ambK, A.ambWarm)
		if A.clock then Lighting.GeographicLatitude = A.lat or 35; Lighting.ClockTime = A.clock   -- a real time of day (17.3 = golden hour, 18 = sunset)
		elseif A.sunDir then MT.sun(A.sunDir[1], A.sunDir[2], A.sunDir[3])   -- shot coords: +y is the way most cameras look, so {0.2, 0.9, 0.2} = a low sun behind the scene
		else
			local sun = f.sun or { -0.5, -0.62, 0.62 }
			MT.sun(sun[1], sun[2], sun[3] * A.sunZ)
		end
	end
	Lighting.Brightness = Lighting.Brightness * A.briMul
	Lighting.ExposureCompensation = Lighting.ExposureCompensation + A.expAdd
	Lighting.ShadowSoftness = A.shadowSoft
	Lighting.EnvironmentSpecularScale = A.spec; Lighting.EnvironmentDiffuseScale = A.diffuse
	local cc = Lighting:FindFirstChild("MTColor")
	if cc then
		cc.Saturation = night and A.nightSat or A.sat
		cc.Contrast = A.con
		cc.TintColor = night and A.nightTint or A.tint
	end
	local at = Lighting:FindFirstChild("Atmosphere")
	if at and night then   -- a purple dusk haze instead of a black sky
		at.Color = A.nightAtmoColor; at.Decay = A.nightAtmoDecay; at.Haze = A.nightHaze; at.Density = A.nightDensity; at.Offset = 0.2
	elseif at then
		at.Density = A.atmoDensity
		if not night then
			at.Color = at.Color:Lerp(A.atmoColor or Color3.fromRGB(255, 226, 190), A.atmoWarm)
			if A.atmoDecay then at.Decay = at.Decay:Lerp(A.atmoDecay, A.decayMix or 0.8) end   -- Decay is what tints the sky at dusk
			if A.atmoHaze then at.Haze = A.atmoHaze end
			if A.atmoOffset then at.Offset = A.atmoOffset end
			if A.glare then at.Glare = A.glare end
		end
	end
	local b = Lighting:FindFirstChild("Bloom"); if b then b.Intensity = b.Intensity * A.bloomMul end
	MT.famExp = Lighting.ExposureCompensation
	MT.dofFar = A.dofFar
end
do
	local family0 = MT.family
	function MT.family(name)
		family0(name)
		if MT.ART.on then MT.artGrade(name) end
	end
end

---------------------------------------------------------------- camera
-- E01 close-ups that show a face and its counter: camOn(name, 4.6, 4.4, 5.0, side, 30, 0.6)
function MT.camOn(name, d, camz, lookz, side, lens, push)
	local a = MT.actors[name] or error("lib11: camOn on unknown actor " .. tostring(name))
	local p = a.base.pos
	local f = math.rad(a.base.facing)
	local fwd = Vector3.new(math.sin(f), 0, math.cos(f)); local right = Vector3.new(fwd.Z, 0, -fwd.X)
	local cam = p + fwd * d + right * (side or 0) + Vector3.new(0, camz, 0)
	-- aim a little below the face so it sits above the caption band (captions sit at about 68 % of the height, eyes would be under them)
	local look = p + Vector3.new(0, lookz - (MT.CAM_FACE_UP or 0.55), 0)
	local function back(v) return { v.X, -v.Z, v.Y } end
	return { back(cam), back(look), lens or 30, push = push, target = name }
end

local frame11 = MT.frame11Base or MT.frame
MT.frame11Base = frame11
function MT.frame(id, f)
	frame11(id, f)
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
	local lightOn = def.lightOn or (MT.camBase and MT.camBase.target)    -- def.lightOn = "hero" lights a character the camera is not built on with camOn
	if MT.ART.portrait and lightOn and not MT.root():FindFirstChild("PortraitKey") then
		MT.portraitLight(lightOn, def.portrait or {})
	end
	if def.roll then   -- Dutch tilt: degrees, or a function of the frame (the camera turns about its view axis; tiles roll with it)
		local r = type(def.roll) == "function" and def.roll(f) or def.roll
		if r ~= 0 then cam.CFrame = cam.CFrame * CFrame.Angles(0, 0, math.rad(r)) end
	end
	if def.flash then Lighting.ExposureCompensation = (MT.famExp or 0) + def.flash(f) end
end
-- roll ramp for def.roll: degrees from a at frame f0 to b at frame f1 (linear, held outside). def.roll = function(f) return MT.rollRamp(f, 1, 45, 0, 6) end
function MT.rollRamp(f, f0, f1, a, b) return a + (b - a) * math.clamp((f - f0) / math.max(1, f1 - f0), 0, 1) end

-- Portrait light (v3.2): a warm key from one side and above, a cool rim from behind the other side, so a face has a shape.
-- Flat front light was the biggest reason a close-up looked cheap next to the @Gneef frames. Runs by itself for any shot whose
-- camera comes from MT.camOn (MT.ART.portrait ~= false); MT.portraitLight(name, o) places it by hand (o.key, o.rim colours, o.side = 1 | -1).
MT.ART.portrait = (MT.ART.portrait == nil) and true or MT.ART.portrait
function MT.portraitLight(name, o)
	o = o or {}
	local a = MT.actors[name]; if not (a and a.base) then return end
	local p = a.base.pos
	local f = math.rad(a.base.facing)
	local fwd = Vector3.new(math.sin(f), 0, math.cos(f)); local right = Vector3.new(fwd.Z, 0, -fwd.X)
	local side = o.side or 1
	local head = p + Vector3.new(0, 4.3 * (a.scale or 1), 0)
	local function mk(name2, pos, light)
		local part = Instance.new("Part"); part.Name = name2; part.Anchored = true; part.CanCollide = false; part.CanQuery = false
		part.Transparency = 1; part.Size = Vector3.new(0.2, 0.2, 0.2); part.CFrame = CFrame.lookAt(pos, head); part.Parent = MT.root()
		light.Parent = part
	end
	local key = Instance.new("SpotLight")
	key.Color = o.key or Color3.fromRGB(255, 214, 170); key.Brightness = o.keyB or (MT.interior and MT.INT and MT.INT.keyB) or MT.ART.keyB or 6; key.Range = 22; key.Angle = 70; key.Face = Enum.NormalId.Front; key.Shadows = true
	mk("PortraitKey", head + fwd * 5.5 + right * (4.2 * side) + Vector3.new(0, 4.5, 0), key)
	local rim = Instance.new("SpotLight")
	rim.Color = o.rim or Color3.fromRGB(150, 180, 255); rim.Brightness = o.rimB or (MT.interior and MT.INT and MT.INT.rimB) or MT.ART.rimB or 4; rim.Range = 22; rim.Angle = 80; rim.Face = Enum.NormalId.Front; rim.Shadows = false
	mk("PortraitRim", head - fwd * 5 - right * (4.5 * side) + Vector3.new(0, 3.5, 0), rim)
end
---------------------------------------------------------------- cast
MT.SKINS = MT.SKINS or { "#F1C9A5", "#E8B98F", "#D9A57E", "#C98F65", "#A8714D", "#8A5A3C" }
-- hair names = MTLib accessories (studio.md §3.0 lists the free ones that fit)
MT.KID_HAIR = MT.KID_HAIR or { "hair_pigtails", "hair_black_short", "hair_floof", "hair_messy_anime", "hair_black_messy", "hair_brown_girl" }
MT.CASTV = MT.CASTV or {}
function MT.kid(i)
	return { shirt = "shirt_c" .. ((i % 9) + 2), pants = "pants_p" .. ((i % 5) + 1), hair = MT.KID_HAIR[(i % #MT.KID_HAIR) + 1],
		skin = MT.SKINS[(i * 5 % #MT.SKINS) + 1], face = "happy" }
end
function MT.cast(name, at, facing, face)
	local base = name:match("^[^#]+")
	local spec = table.clone(MT.CASTV[base] or MT.kid(tonumber(base:match("%d+")) or 1))
	if face then spec.face = face end
	return MT.actor(name, spec, at, facing)
end
-- k kids named "<prefix><i0+1..i0+k>" in a ring of radius r around (cx, cy), all facing faceAt (default the centre)
function MT.around(cx, cy, r, k, i0, faceAt, prefix)
	local list = {}
	for j = 1, k do
		local ang = (j - 1) / k * 2 * math.pi + 0.3
		local x, y = cx + r * math.cos(ang), cy + r * math.sin(ang)
		local name = (prefix or "kid") .. (i0 + j)
		MT.cast(name, { x, y }, MT.faceTo({ x, y }, faceAt or { cx, cy }), "happy")
		table.insert(list, name)
	end
	return list
end
-- everyone in the list talks, mouths out of step; only the mouth moves when <face>_t exists (make_talk_faces.py)
function MT.chatter(list, f, faceName)
	faceName = faceName or "happy"
	local alt = MT.FACES[faceName .. "_t"] and (faceName .. "_t") or "talk"
	for j, k in ipairs(list) do MT.actorFace(k, (math.floor((f + j * 3) / 5) % 2 == 0) and alt or faceName) end
end

---------------------------------------------------------------- light, hits, falls, runs, set dressing
-- a warm light in front of a face (night shots; without it E01's faces went purple). Call in build() after the cast.
function MT.faceLight(name, o)
	o = o or {}
	local a = MT.actors[name]; if not a then return end
	local f = math.rad(a.base.facing)
	local fwd = Vector3.new(math.sin(f), 0, math.cos(f)); local right = Vector3.new(fwd.Z, 0, -fwd.X)
	local p = a.base.pos + Vector3.new(0, (o.height or 5) * a.scale, 0) + fwd * (o.dist or 3.5) + right * (o.side or 1.5)
	local part = Instance.new("Part")
	part.Name = name .. "_faceLight"; part.Anchored = true; part.CanCollide = false; part.CanQuery = false; part.CastShadow = false
	part.Transparency = 1; part.Size = Vector3.new(0.2, 0.2, 0.2); part.Position = p; part.Parent = MT.root()
	local l = Instance.new("PointLight")
	l.Color = o.color or RGB(255, 196, 140); l.Brightness = o.brightness or 1.6; l.Range = o.range or 9; l.Shadows = false; l.Parent = part
	return part
end
-- a hit: shake jumps to amp degrees at frame f0 and dies away. def.shake = function(f) return MT.punch(f, 1, 2.5) end
function MT.punch(f, f0, amp, decay)
	if f < f0 then return 0 end
	return amp * math.exp(-(f - f0) / (decay or 6))
end
-- white flash: exposure jumps by amount at f0 and fades over len frames. def.flash = function(f) return MT.flashAt(f, 1, 4, 3) end
function MT.flashAt(f, f0, len, amount)
	if f < f0 or f > f0 + len then return 0 end
	return (amount or 3) * (1 - (f - f0) / len)
end
-- height of a dropped prop at frame f: falls from z0 to z1 starting at f0, speeding up like gravity (len frames, default 9),
-- then one small bounce (bounce = fraction of the drop height, default 0.15; 0 = none). E03 s06 dropped the lunchbox at a
-- constant speed over 22 frames and it floated down. lb.Position = Vector3.new(x, MT.drop(f, 1, 2.4, 0.35), y)
function MT.drop(f, f0, z0, z1, len, bounce)
	len = len or 9; bounce = bounce or 0.15
	if f <= f0 then return z0 end
	local t = (f - f0) / len
	if t <= 1 then return z0 - (z0 - z1) * t * t end
	local bl = 2 * math.sqrt(bounce)            -- bounce length in units of len, same gravity as the fall
	local u = (t - 1) / math.max(bl, 1e-3)
	if bounce <= 0 or u >= 1 then return z1 end
	return z1 + (z0 - z1) * bounce * 4 * u * (1 - u)
end
-- fall flat on the back from frame f0 over len frames (the R6 "fall" clip plays on the way down). Call every frame from f0 on.
function MT.fallBack(name, f, f0, len)
	local a = MT.actors[name]; if not a or f < f0 then return end
	local p = math.clamp((f - f0) / (len or 10), 0, 1)
	a.tilt = 90 * p * p                       -- speeds up like a real fall (lib10 pivots the body on its feet)
	a.lift = 0.5 * a.scale * p                -- half a torso up, so the lying body rests on the floor, not in it
	MT.anim(name, "fall", f0)
end
-- the reference's signature shot: run straight at the camera and stop `stop` studs in front of it (walk = true to walk)
function MT.runAt(name, f, f0, f1, from, cam, stop, walk)
	local dx, dy = cam[1] - from[1], cam[2] - from[2]
	local d = math.max(0.01, math.sqrt(dx * dx + dy * dy))
	local k = math.max(0, d - (stop or 2.5)) / d
	MT.walkTo(name, f, f0, f1, from, { from[1] + dx * k, from[2] + dy * k, from[3] }, not walk)
end
-- set dressing that may not be inserted yet: places the MTLib model when it is there, otherwise just notes it
function MT.putIf(name, at, o)
	if MT.LIB and MT.LIB:FindFirstChild(name) then return MT.put(name, at, o) end
	MT.missingLib = MT.missingLib or {}
	MT.missingLib[name] = true
end
function MT.missingList()
	local t = {}
	for k in pairs(MT.missingLib or {}) do table.insert(t, k) end
	table.sort(t); return table.concat(t, " ")
end

---------------------------------------------------------------- shots
-- Previews are one-frame shots that are not part of the episode: the cast and set sheets (stage_capture.py) render MT.frame(id, 1)
-- for each of them. They survive MT.resetShots, so an episode's cast.lua / sets.lua can register them before shots.lua runs.
MT.PREVIEWS = {}; MT.PREVIEWDEFS = {}
function MT.resetShots()
	MT.SHOTS = {}; MT.shotIdx = 0
	for id, d in pairs(MT.PREVIEWDEFS) do MT.SHOTS[id] = d end
end
function MT.preview(id, build)
	if not MT.PREVIEWDEFS[id] then table.insert(MT.PREVIEWS, id) end
	local d = { build = build, n = 1, idx = 0 }
	MT.PREVIEWDEFS[id] = d; MT.SHOTS[id] = d
end
-- CAST sheet: MT.castPreview({ "me", "brad" }, { me = { "smile", "scared", "shocked" } }) registers, per character, cast_<name>_front,
-- cast_<name>_three (3/4 view) and cast_<name>_face_<face> for each listed face (default: the character's own face). The character
-- stands alone on a neutral grey stage so outfit, hair and silhouette can be judged.
function MT.castPreview(names, faces)
	local function stage(name, face, d, camz, lookz, side, lens)
		return function()
			MT.box("stage_floor", { 60, 60, 1 }, { 0, 0, -0.5 }, "#8F9299")
			MT.box("stage_back", { 60, 1, 24 }, { 0, 14, 12 }, "#C8CAD0")
			MT.family("mid-neutral-normal")
			MT.cast(name, { 0, 0 }, 0, face)
			return MT.camOn(name, d, camz, lookz, side, lens)
		end
	end
	for _, name in ipairs(names) do
		MT.preview("cast_" .. name .. "_front", stage(name, nil, 11, 3.4, 3.0, 0, 32))
		MT.preview("cast_" .. name .. "_three", stage(name, nil, 11, 3.4, 3.0, 5.5, 32))
		local own = (MT.CASTV[name] or {}).face
		for _, f in ipairs((faces and faces[name]) or { own or "neutral" }) do
			MT.preview("cast_" .. name .. "_face_" .. f, stage(name, f, 3.6, 4.4, 5.0, 0, 30))
		end
	end
end
-- SET sheet: MT.setPreview("oak", function() oakStreet("green", "mid-neutral-normal", false) end, { cast = { { "me", { 2, 0 }, -70 } } })
-- registers set_<name>_wide, set_<name>_low and set_<name>_top: the set built and lit, the cast who appear standing in it.
-- opts.cams = { wide = { loc, look, lens }, low = ..., top = ... } overrides a camera (shot coordinates: x right, y forward, z up).
function MT.setPreview(name, buildSet, opts)
	opts = opts or {}
	local cams = {
		wide = { { 0, -28, 8 }, { 0, 0, 3.5 }, 46 },
		low = { { -4, -9, 1.5 }, { 2, 0, 3.2 }, 34 },
		top = { { 0, -0.5, 48 }, { 0, 0, 0 }, 42 },
	}
	for k, v in pairs(opts.cams or {}) do cams[k] = v end
	for view, cam in pairs(cams) do
		MT.preview("set_" .. name .. "_" .. view, function()
			buildSet()
			for _, c in ipairs(opts.cast or {}) do MT.cast(c[1], c[2], c[3] or 0, c[4]) end
			return { cam[1], cam[2], cam[3] }
		end)
	end
end
function MT.listPreviews() return table.concat(MT.PREVIEWS, ",") end
function MT.shot(id, def)
	MT.shotIdx = (MT.shotIdx or 0) + 1
	def.idx = MT.shotIdx
	def.n = (MT.N and MT.N[id]) or def.n or 30
	MT.SHOTS[id] = def
	return def
end
MT.resetShots()

return "lib11 loaded (episode helpers)"
