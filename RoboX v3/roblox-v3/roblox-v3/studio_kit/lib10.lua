-- lib10: route C cast (studio.md §3.1). Real R6 avatars built by Roblox from a HumanoidDescription, moved by
-- Roblox's own R6 animations (idle, walk, run, jump, wave, point, cheer, laugh, sit), stepped frame-exact in Edit mode.
-- Load after lib9. Actors live in MT.actors (not MT.rigs), so the anchored-parts code (MT.apply, MT.resolve, arm guard)
-- never touches them. Coordinates and facing use the same shot convention as MT.make: V(x, y, z) with z up.
--
-- In a shot:
--   build = function() ...; MT.actor("me", { shirt = "shirt_me", pants = "pants_me", hair = "hair_afro" }, { 0, 0 }, 180); return cam end
--   act   = function(f, n, t) MT.walkTo("me", f, 1, 24, { 0, 0 }, { 0, -8 }) ; MT.anim("mom", "wave", 10) ; MT.actorFace("me", "oh") end
-- Every frame an actor starts from its build position/facing playing "idle"; act() overrides that for this frame only.
local MT = shared.MT
local Players = game:GetService("Players")
local rad = math.rad

-- Roblox-owned default R6 animations (the classic R6 Animate script). Check each one loads before an episode:
-- MT.checkAnims() returns the length of every clip (0 = did not load).
MT.R6ANIM = MT.R6ANIM or {
	idle = 180435571, idle2 = 180435792, walk = 180426354, run = 180426354, jump = 125750702, fall = 180436148,
	climb = 180436334, sit = 178130996, wave = 128777973, point = 128853357, laugh = 129423131, cheer = 129423030,
	dance = 182435998,
}
-- R6 Animate plays walk at speed = studs per second / 14.5; run is the same clip, faster.
MT.R6_STRIDE = 14.5
-- How a frame's pose is reached: "seek" sets TimePosition then StepAnimations(0) (any frame order, re-renders safe);
-- "step" replays from the clip start with StepAnimations(dt). runR6Test.lua tells you which one this Studio supports.
MT.ANIM_MODE = MT.ANIM_MODE or "seek"
MT.actors = MT.actors or {}

local SKIN = "#E8B98F"

local function ensureAnimator(hum)
	local a = hum:FindFirstChildOfClass("Animator")
	if not a then a = Instance.new("Animator"); a.Parent = hum end
	return a
end

local function loadTrack(actor, clip)
	local tr = actor.tracks[clip]
	if tr then return tr end
	local id = MT.R6ANIM[clip]
	if not id then error("lib10: unknown clip " .. tostring(clip)) end
	local a = Instance.new("Animation")
	a.AnimationId = "rbxassetid://" .. id
	tr = actor.animator:LoadAnimation(a)
	tr.Looped = (clip == "idle" or clip == "idle2" or clip == "walk" or clip == "run" or clip == "dance" or clip == "climb")
	tr.Priority = Enum.AnimationPriority.Action
	local t0 = os.clock()
	while tr.Length == 0 and os.clock() - t0 < 5 do task.wait() end   -- clips load asynchronously
	actor.tracks[clip] = tr
	return tr
end

local function addHair(actor, libName)
	local src = MT.LIB and MT.LIB:FindFirstChild(libName)
	if not src then warn("lib10: no hair " .. tostring(libName) .. " in MTLib"); return end
	local acc = src:IsA("Accessory") and src:Clone() or src:FindFirstChildWhichIsA("Accessory", true)
	if not acc then warn("lib10: " .. libName .. " has no Accessory"); return end
	if acc.Parent ~= nil and acc ~= src then acc = acc:Clone() end
	for _, d in ipairs(acc:GetDescendants()) do
		if d:IsA("BasePart") then d.Anchored = false; d.CanCollide = false; d.CanQuery = true end
	end
	actor.hum:AddAccessory(acc)       -- welds by HairAttachment on the real R6 head: no sinking, no floating
	local col = MT.HAIR_COLOR and MT.HAIR_COLOR[actor.name:match("^[^#]+")] or actor.spec.hairColor
	local h = acc:FindFirstChild("Handle")
	if col and h then
		local m = h:FindFirstChildWhichIsA("SpecialMesh")
		if m then m.TextureId = ""; m.VertexColor = Vector3.new(1, 1, 1) end
		if h:IsA("MeshPart") then pcall(function() h.TextureID = "" end) end
		h.Color = MT.C(col)
	end
end

-- actor(name, spec, {x, y, z}, facingDeg)
-- spec: shirt / pants = keys in shared.MT_CLOTH ("shirt_me") or rbxassetid strings; skin "#hex"; hair = MTLib name;
--       hairColor "#hex"; face = MT.FACES key; scale (uniform, default 1)
function MT.actor(name, spec, at, facing)
	spec = spec or {}
	local desc = Instance.new("HumanoidDescription")
	local skin = MT.C(spec.skin or SKIN)
	desc.HeadColor, desc.TorsoColor = skin, skin
	desc.LeftArmColor, desc.RightArmColor, desc.LeftLegColor, desc.RightLegColor = skin, skin, skin, skin
	local m = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
	m.Name = name
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("LuaSourceContainer") then d:Destroy() end          -- the Animate script never runs in Edit; we drive tracks ourselves
	end
	local hum = m:FindFirstChildOfClass("Humanoid")
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	local root = m:FindFirstChild("HumanoidRootPart")
	for _, p in ipairs(m:GetDescendants()) do
		if p:IsA("BasePart") then p.Anchored = (p == root); p.CanCollide = false; p.CanQuery = (p ~= root) end
	end
	local CL = shared.MT_CLOTH or {}
	local function tmpl(v) if not v then return "" end; return CL[v] or v end
	local sh = m:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", m); sh.ShirtTemplate = tmpl(spec.shirt)
	local pa = m:FindFirstChildOfClass("Pants") or Instance.new("Pants", m); pa.PantsTemplate = tmpl(spec.pants)
	m.Parent = MT.root()
	if spec.scale and spec.scale ~= 1 then m:ScaleTo(spec.scale) end
	local head = m:FindFirstChild("Head")
	local face = head:FindFirstChildOfClass("Decal") or Instance.new("Decal", head)
	face.Name = "face"; face.Face = Enum.NormalId.Front
	local actor = {
		name = name, model = m, hum = hum, root = root, head = head, faceDecal = face, spec = spec,
		animator = ensureAnimator(hum), tracks = {}, scale = spec.scale or 1,
	}
	actor.base = { pos = MT.V(at[1], at[2], at[3] or 0), facing = facing or 0, face = spec.face or "neutral" }
	MT.actors[name] = actor
	if spec.hair then addHair(actor, spec.hair) end
	MT.actorFace(name, actor.base.face)
	actor.pos, actor.facing = actor.base.pos, actor.base.facing
	MT.placeActor(name)
	return actor
end

function MT.actorFace(name, face)
	local a = MT.actors[name]
	a.wantFace = face
	if a.faceName ~= face then
		a.faceName = face
		a.faceDecal.Texture = MT.FACES[face] or MT.FACES.neutral or ""
	end
end

-- root on the ground under pos, front toward facing (same convention as MT.apply)
function MT.placeActor(name)
	local a = MT.actors[name]
	local f = rad(a.facing)
	local fwd = Vector3.new(math.sin(f), 0, math.cos(f))
	local p = a.pos + Vector3.new(0, 3 * a.scale + (a.lift or 0), 0)
	a.model:PivotTo(CFrame.lookAt(p, p + fwd))
end

-- what an actor plays this frame: anim(name, clip, startFrame, speed)
function MT.anim(name, clip, f0, speed)
	local a = MT.actors[name]
	a.want = { clip = clip, f0 = f0 or 1, speed = speed or 1 }
end

-- walk (or run) from -> to between frames f0 and f1; feet keep pace with the ground speed
function MT.walkTo(name, f, f0, f1, from, to, run)
	local a = MT.actors[name]
	local p = math.clamp((f - f0) / math.max(1, f1 - f0), 0, 1)
	local x = from[1] + (to[1] - from[1]) * p
	local y = from[2] + (to[2] - from[2]) * p
	local z = (from[3] or 0) + ((to[3] or 0) - (from[3] or 0)) * p
	a.pos = MT.V(x, y, z)
	a.facing = MT.faceTo(from, to)
	if f < f0 or f > f1 then a.want = { clip = "idle", f0 = 1, speed = 1 }; return end
	local dist = (MT.V(to[1], to[2], to[3] or 0) - MT.V(from[1], from[2], from[3] or 0)).Magnitude
	local studsPerSec = dist / math.max(1 / 30, (f1 - f0) / 30)
	a.want = { clip = run and "run" or "walk", f0 = f0, speed = studsPerSec / MT.R6_STRIDE * a.scale ^ -1 }
end

-- pose every actor for frame f: the wanted clip at its local time, every other clip stopped
local function stepActors(f)
	for name, a in pairs(MT.actors) do
		local w = a.want or { clip = "idle", f0 = 1, speed = 1 }
		local tr = loadTrack(a, w.clip)
		for clip, other in pairs(a.tracks) do
			if other ~= tr and other.IsPlaying then other:Stop(0) end
		end
		local tl = math.max(0, (f - w.f0) / 30 * w.speed)
		if tr.Looped and tr.Length > 0 then tl = tl % tr.Length else tl = math.min(tl, math.max(0, tr.Length - 1 / 60)) end
		if MT.ANIM_MODE == "seek" then
			if not tr.IsPlaying then tr:Play(0, 1, 0) end
			tr:AdjustSpeed(0)
			tr.TimePosition = tl
			a.animator:StepAnimations(0)
		else
			tr:Stop(0); tr:Play(0, 1, 1)
			a.animator:StepAnimations(0)
			local left = tl
			while left > 0 do local dt = math.min(left, 1 / 30); a.animator:StepAnimations(dt); left -= dt end
		end
		MT.placeActor(name)
	end
end
MT.stepActors = stepActors

-- hooks: clear forgets actors; frame resets them to their build state, runs the shot (inside frameBase), then poses them
local clearBase = MT.clearR6base or MT.clear
MT.clearR6base = clearBase
function MT.clear()
	clearBase()
	MT.actors = {}
end

local frameBase = MT.frameR6base or MT.frame
MT.frameR6base = frameBase
local BLINKY = { neutral = 1, smile = 1, happy = 1, sad = 1, nervous = 1, oh = 1, angry = 1, smirk = 1 }
function MT.frame(id, f)
	if MT.cur ~= id then MT.build(id) end
	local def = MT.SHOTS[id]
	for name, a in pairs(MT.actors) do      -- reset before def.act runs inside frameBase
		a.pos, a.facing, a.lift, a.want = a.base.pos, a.base.facing, 0, nil
		local face = a.base.face
		if def.speak == name then face = (math.floor(f / 4) % 2 == 0) and "talk" or a.base.face
		elseif BLINKY[face] and (def.n or 30) >= 20 and f % 97 >= 90 and f % 97 < 93 then face = "blink" end
		a.wantFace = face
	end
	frameBase(id, f)
	for name, a in pairs(MT.actors) do MT.actorFace(name, a.wantFace or a.base.face) end
	stepActors(f)
end

-- clip lengths (0 = not loaded / not allowed): run once per Studio session before an episode
function MT.checkAnims()
	MT.clear()
	local a = MT.actor("anim_check", {}, { 0, 0 }, 0)
	local out = {}
	for clip in pairs(MT.R6ANIM) do
		local ok, tr = pcall(loadTrack, a, clip)
		table.insert(out, string.format("%s=%.2f", clip, ok and tr.Length or -1))
	end
	table.sort(out)
	MT.clear()
	return table.concat(out, " ")
end

-- close-up on an actor (standard R6 head centre 4.5 studs up, not the 1.25x MT head)
function MT.cuActor(name, o)
	o = o or {}
	local a = MT.actors[name]
	local s = a.scale
	local fwd = Vector3.new(math.sin(rad(a.base.facing)), 0, math.cos(rad(a.base.facing)))
	local right = Vector3.new(fwd.Z, 0, -fwd.X)
	local eye = a.base.pos + Vector3.new(0, 4.55 * s, 0)
	local cam = eye + fwd * (o.dist or 3.9) * 1.19 * s + right * (o.side or 0) * 1.3 + Vector3.new(0, (o.height or -0.75) * s, 0)
	local function back(v) return { v.X, -v.Z, v.Y } end     -- Roblox -> shot coords for MT.camBase
	return { back(cam), back(eye + Vector3.new(0, -0.1 * s, 0)), o.lens or 28 }
end

-- no-clipping check for actors (studio.md §4 rule; MT.clips only knows the anchored rigs). Run it on the first, middle and
-- last frame of every shot, like MT.clips. Each body part is shrunk by `inset`, so touching passes and passing through doesn't.
local BODY = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
function MT.actorClips(inset)
	inset = inset or 0.18
	local hits = {}
	local owner = {}
	for name, a in pairs(MT.actors) do owner[a.model] = name end
	for name, rig in pairs(MT.rigs) do owner[rig.model] = name end
	for name, a in pairs(MT.actors) do
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { a.model }
		for _, k in ipairs(BODY) do
			local p = a.model:FindFirstChild(k)
			if p then
				local sz = p.Size - Vector3.new(inset, inset, inset) * 2
				for _, q in ipairs(workspace:GetPartBoundsInBox(p.CFrame, sz, params)) do
					if q.Transparency < 0.95 and q.Name ~= "Handle" and not q:IsDescendantOf(workspace.Terrain) then
						local m = q:FindFirstAncestorOfClass("Model")
						local who = m and owner[m]
						table.insert(hits, name .. "." .. k .. " x " .. (who and (who .. ".") or "") .. q.Name)
					end
				end
			end
		end
	end
	return hits
end

return "lib10 loaded (R6 actors + R6 animations)"
