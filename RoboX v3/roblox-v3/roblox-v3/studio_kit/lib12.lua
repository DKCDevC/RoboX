-- lib12: R6 Expressive Acting & Custom Animation Engine (loaded after lib11 by load.py).
-- Solves limited default R6 acting by:
--   1. MT.registerAnim(name, id, looped)  -- plug in custom Roblox Animation IDs (Moon Animator / Animation Editor / RoMixamo)
--   2. 19 built-in keyframed R6 acting clips (shock, panic, cry_kneel, beg, angry_stomp, whisper, think, shrug,
--      facepalm, hold_item, hold_both, push, sneak, collapse, celebrate, nod, headshake, hug_self, cross_arms)
--      driven directly on Motor6D.Transform after Animator:StepAnimations, with easing and upper-body/additive layering.
--   3. MT.lookAt(name, target, weight)    -- turn head (+ subtle torso) toward another actor, {x,y,z}, or "camera"
--   4. MT.breathe(name, f, amp)           -- subtle alive breathing motion when standing
--
-- Calling MT.anim(name, "panic", f0) automatically dispatches to MT.actPose if "panic" is in MT.ACTING.
local MT = shared.MT
local rad = math.rad
local clamp = math.clamp
local sin, cos, pi = math.sin, math.cos, math.pi

MT.CUSTOM_LOOP = MT.CUSTOM_LOOP or {}

-- 1. Register a custom Roblox Animation ID (exported from Moon Animator / Animation Editor / RoMixamo)
function MT.registerAnim(name, assetId, looped)
	MT.R6ANIM[name] = assetId
	if looped ~= nil then MT.CUSTOM_LOOP[name] = looped end
end

-- Helper: convert a character-local rotation (rx, ry, rz in deg; +X right, +Y up, -Z forward) & optional offset
-- into Motor6D.Transform space (exact for every R6 joint regardless of its C0 orientation).
local function localTransform(joint, rx, ry, rz, off)
	local c0Rot = joint.C0 - joint.C0.Position
	local localCF = CFrame.Angles(rad(rx or 0), rad(ry or 0), rad(rz or 0))
	if off then localCF = CFrame.new(off[1] or 0, off[2] or 0, off[3] or 0) * localCF end
	return c0Rot:Inverse() * localCF * c0Rot
end

local function getJoints(a)
	if a._joints then return a._joints end
	local m = a.model
	local root = m:FindFirstChild("HumanoidRootPart")
	local torso = m:FindFirstChild("Torso")
	local j = {}
	if root then j.root = root:FindFirstChild("RootJoint") end
	if torso then
		j.head = torso:FindFirstChild("Neck")
		j.armL = torso:FindFirstChild("Left Shoulder")
		j.armR = torso:FindFirstChild("Right Shoulder")
		j.legL = torso:FindFirstChild("Left Hip")
		j.legR = torso:FindFirstChild("Right Hip")
	end
	a._joints = j
	return j
end

-- Easing helpers
local function easeOut(t) t = clamp(t, 0, 1); return 1 - (1 - t) ^ 3 end
local function easeInOut(t) t = clamp(t, 0, 1); return t * t * (3 - 2 * t) end
local function easeOutBack(t)
	t = clamp(t, 0, 1)
	local c1 = 1.70158
	local c3 = c1 + 1
	return 1 + c3 * ((t - 1) ^ 3) + c1 * ((t - 1) ^ 2)
end

-- 2. Built-in expressive R6 acting library
-- Each function(t) returns a table of joint poses:
--   { root = {rx, ry, rz, {ox,oy,oz}}, head = {rx,ry,rz}, armL = {rx,ry,rz}, armR = {rx,ry,rz}, legL = ..., legR = ... }
-- Convention in character-local space (+X right, +Y up, -Z forward):
--   arms: +rx raises arm forward/up (90 = horizontal forward, 150 = high up); +rz abducts Left Arm out, -rz abducts Right Arm out
--   head: +rx looks up, -rx looks down; +ry turns left, -ry turns right; +rz tilts right ear down
--   root: -rx leans forward, +rx leans back; off[2] < 0 crouches/kneels
MT.ACTING = {
	shock = function(t)
		local p = easeOutBack(t / 0.22)
		local vib = sin(t * 42) * 2.5 * clamp(1 - t * 0.8, 0.2, 1)
		return {
			root = { 14 * p, 0, 0, { 0, -0.15 * p, 0.35 * p } },
			head = { 12 * p + vib, 0, vib * 0.6 },
			armL = { 115 * p, 0, 28 * p },
			armR = { 115 * p, 0, -28 * p },
			legL = { -14 * p, 0, 6 * p },
			legR = { -14 * p, 0, -6 * p },
		}
	end,

	panic = function(t)
		local p = easeOut(t / 0.2)
		local shake = sin(t * 28) * 16
		local bob = sin(t * 22) * 4
		return {
			root = { -8 * p, shake * 0.2, 0, { 0, -0.1 * p, 0 } },
			head = { -6 * p + bob, shake, shake * 0.4 },
			armL = { 148 * p + bob, -18 * p, 12 * p },
			armR = { 148 * p - bob, 18 * p, -12 * p },
		}
	end,

	cry_kneel = function(t)
		local p = easeInOut(t / 0.35)
		local sob = sin(t * 14) * 5
		return {
			root = { -26 * p, 0, 0, { 0, -1.25 * p, 0 } },
			head = { -28 * p + sob, 0, sin(t * 7) * 4 },
			armL = { 112 * p + sob * 0.6, -24 * p, 8 * p },
			armR = { 112 * p + sob * 0.6, 24 * p, -8 * p },
			legL = { -78 * p, 0, 8 * p },
			legR = { -78 * p, 0, -8 * p },
		}
	end,

	beg = function(t)
		local p = easeOut(t / 0.28)
		local plea = sin(t * 10) * 6
		return {
			root = { -16 * p, 0, 0, { 0, -0.2 * p, 0 } },
			head = { 10 * p + plea * 0.4, 0, 6 * p },
			armL = { 78 * p + plea, -26 * p, -6 * p },
			armR = { 78 * p + plea, 26 * p, 6 * p },
		}
	end,

	angry_stomp = function(t)
		local p = easeOut(t / 0.18)
		local stomp = math.max(0, sin(t * 14))
		local quiver = sin(t * 48) * 3
		return {
			root = { -14 * p, 0, 0, { 0, -0.08 * (1 - stomp), 0 } },
			head = { -10 * p, quiver, 0 },
			armL = { 38 * p + quiver, 0, 26 * p },
			armR = { 38 * p - quiver, 0, -26 * p },
			legR = { 34 * stomp * p, 0, 0 },
		}
	end,

	whisper = function(t)
		local p = easeInOut(t / 0.25)
		return {
			root = { -16 * p, 14 * p, 0 },
			head = { -6 * p, -18 * p, 8 * p },
			armR = { 106 * p, 22 * p, -10 * p },
			armL = { 10 * p, 0, 8 * p },
		}
	end,

	think = function(t)
		local p = easeInOut(t / 0.3)
		return {
			root = { -4 * p, -8 * p, 0 },
			head = { 6 * p, 10 * p, 12 * p },
			armR = { 104 * p, 24 * p, -8 * p },
			armL = { 28 * p, -20 * p, 10 * p },
		}
	end,

	shrug = function(t)
		local p = easeOutBack(t / 0.25)
		return {
			root = { 4 * p, 0, 0 },
			head = { 4 * p, 0, 14 * p },
			armL = { 32 * p, 0, 52 * p },
			armR = { 32 * p, 0, -52 * p },
		}
	end,

	facepalm = function(t)
		local p = easeOut(t / 0.22)
		local shake = sin(t * 10) * 6 * clamp((t - 0.22) * 3, 0, 1)
		return {
			root = { -8 * p, 0, 0 },
			head = { -16 * p, shake, 0 },
			armR = { 126 * p, 20 * p, -6 * p },
		}
	end,

	hold_item = function(t)
		local p = easeOut(t / 0.2)
		local bob = sin(t * 4) * 2
		return {
			armR = { 96 * p + bob, 8 * p, -8 * p },
		}
	end,

	hold_both = function(t)
		local p = easeOut(t / 0.2)
		local bob = sin(t * 4) * 2
		return {
			armL = { 76 * p + bob, -18 * p, 4 * p },
			armR = { 76 * p + bob, 18 * p, -4 * p },
		}
	end,

	push = function(t)
		local p = easeOutBack(t / 0.18)
		return {
			root = { -22 * p, 0, 0, { 0, -0.1 * p, -0.35 * p } },
			head = { 10 * p, 0, 0 },
			armL = { 98 * p, 0, 8 * p },
			armR = { 98 * p, 0, -8 * p },
			legL = { -24 * p, 0, 0 },
			legR = { 20 * p, 0, 0 },
		}
	end,

	sneak = function(t)
		local p = easeInOut(t / 0.25)
		local sway = sin(t * 6) * 6
		return {
			root = { -24 * p, sway * 0.5, 0, { 0, -0.45 * p, 0 } },
			head = { 18 * p, -sway, 0 },
			armL = { 42 * p, 0, 24 * p },
			armR = { 42 * p, 0, -24 * p },
		}
	end,

	collapse = function(t)
		local p = easeInOut(t / 0.45)
		return {
			root = { -84 * p, 0, 12 * p, { 0, -2.35 * p, -0.6 * p } },
			head = { -15 * p, 24 * p, 18 * p },
			armL = { 48 * p, 0, 42 * p },
			armR = { 34 * p, 0, -54 * p },
			legL = { 14 * p, 0, 12 * p },
			legR = { -10 * p, 0, -14 * p },
		}
	end,

	celebrate = function(t)
		local hop = math.abs(sin(t * 11))
		local wave = sin(t * 16) * 14
		return {
			root = { 6 * hop, 0, 0, { 0, 0.75 * hop, 0 } },
			head = { 12 * hop, 0, wave * 0.3 },
			armL = { 155 + wave, 0, 24 },
			armR = { 155 - wave, 0, -24 },
			legL = { -18 * hop, 0, 8 * hop },
			legR = { -18 * hop, 0, -8 * hop },
		}
	end,

	nod = function(t)
		local d = sin(t * 16) * 18 * clamp(1.2 - t * 0.5, 0.35, 1)
		return { head = { -math.abs(d), 0, 0 } }
	end,

	headshake = function(t)
		local y = sin(t * 20) * 24 * clamp(1.2 - t * 0.5, 0.35, 1)
		return { head = { 0, y, 0 } }
	end,

	hug_self = function(t)
		local p = easeOut(t / 0.25)
		local shiver = sin(t * 38) * 2.5
		return {
			root = { -8 * p, shiver * 0.4, 0 },
			head = { -12 * p, shiver, 0 },
			armL = { 74 * p, -26 * p, -6 * p },
			armR = { 74 * p, 26 * p, 6 * p },
		}
	end,

	cross_arms = function(t)
		local p = easeOut(t / 0.25)
		return {
			root = { 4 * p, 0, 0 },
			head = { -4 * p, 0, -6 * p },
			armL = { 62 * p, -30 * p, -4 * p },
			armR = { 62 * p, 30 * p, 4 * p },
		}
	end,

	point_accuse = function(t)
		local p = easeOutBack(t / 0.18)
		local thrust = sin(clamp(t * 8, 0, pi)) * 0.12
		return {
			root = { -12 * p, -18 * p, 0, { 0, 0, -thrust } },
			head = { 4 * p, 18 * p, 0 },
			armR = { 94 * p, -10 * p, -6 * p },
			armL = { 18 * p, 0, 16 * p },
		}
	end,

	flinch = function(t)
		local p = easeOutBack(t / 0.16)
		return {
			root = { 16 * p, -12 * p, 0, { 0, -0.25 * p, 0.45 * p } },
			head = { -10 * p, 18 * p, -10 * p },
			armL = { 118 * p, -20 * p, 18 * p },
			armR = { 118 * p, 20 * p, -18 * p },
			legL = { -18 * p, 0, 8 * p },
			legR = { 14 * p, 0, -8 * p },
		}
	end,

	step_back = function(t)
		local p = easeOut(t / 0.28)
		local sway = sin(t * 10) * 8 * (1 - p * 0.5)
		return {
			root = { 10 * p, 0, 0, { 0, -0.08 * p, 0.7 * p } },
			head = { 8 * p, sway, 0 },
			armL = { 54 * p, 0, 32 * p },
			armR = { 54 * p, 0, -32 * p },
			legL = { 22 * p, 0, 0 },
			legR = { -22 * p, 0, 0 },
		}
	end,

	slam_desk = function(t)
		local strike = clamp(t / 0.16, 0, 1)
		local hold = easeOut(strike)
		local bounce = (t > 0.16) and sin((t - 0.16) * 28) * 6 * math.exp(-(t - 0.16) * 6) or 0
		return {
			root = { -26 * hold + bounce * 0.4, 0, 0, { 0, -0.15 * hold, -0.25 * hold } },
			head = { -12 * hold + bounce, 0, 0 },
			armL = { 92 * hold + bounce, 0, 14 * hold },
			armR = { 92 * hold + bounce, 0, -14 * hold },
		}
	end,

	grab_collar = function(t)
		local p = easeOutBack(t / 0.2)
		local shake = sin(t * 24) * 4
		return {
			root = { -18 * p, 0, 0, { 0, 0, -0.28 * p } },
			head = { 6 * p, shake * 0.5, 0 },
			armL = { 96 * p, -22 * p, 4 * p },
			armR = { 96 * p, 22 * p, -4 * p },
		}
	end,

	pray = function(t)
		local p = easeInOut(t / 0.28)
		local nod = sin(t * 5) * 3
		return {
			root = { -10 * p, 0, 0 },
			head = { -18 * p + nod, 0, 0 },
			armL = { 84 * p, -32 * p, -6 * p },
			armR = { 84 * p, 32 * p, 6 * p },
		}
	end,

	tired_slump = function(t)
		local p = easeInOut(t / 0.35)
		local sigh = sin(t * 3.2) * 3
		return {
			root = { -18 * p + sigh * 0.5, 0, 0, { 0, -0.18 * p, 0 } },
			head = { -28 * p + sigh, 0, 8 * p },
			armL = { 16 * p, 0, 6 * p },
			armR = { 16 * p, 0, -6 * p },
		}
	end,

	power_up = function(t)
		local p = easeOut(t / 0.3)
		local hover = sin(t * 6) * 0.18
		local vib = sin(t * 45) * 2.5
		return {
			root = { 10 * p + vib * 0.4, 0, 0, { 0, 0.85 * p + hover, 0 } },
			head = { 18 * p, vib, 0 },
			armL = { 48 * p, 0, 56 * p + vib },
			armR = { 48 * p, 0, -56 * p - vib },
			legL = { -12 * p, 0, 12 * p },
			legR = { 12 * p, 0, -12 * p },
		}
	end,
}

-- 3. Public acting APIs (called inside shot def.act(f, n, t))
-- MT.actPose(name, actName, f, f0, opts)
--   opts = { speed = 1, weight = 1, upperOnly = false, additive = false }
function MT.actPose(name, actName, f, f0, opts)
	local a = MT.actors[name]; if not a then return end
	if not MT.ACTING[actName] then error("lib12: unknown acting clip " .. tostring(actName)) end
	a.actLayers = a.actLayers or {}
	table.insert(a.actLayers, {
		clip = actName,
		f = f or 1,
		f0 = f0 or 1,
		opts = opts or {},
	})
end

-- MT.lookAt(name, target, weight)
--   target: another actor's name ("mom"), shot coords {x, y, z}, or "camera"
function MT.lookAt(name, target, weight)
	local a = MT.actors[name]; if not a then return end
	a.wantLookAt = { target = target, weight = weight or 1 }
end

-- MT.breathe(name, f, amp)
function MT.breathe(name, f, amp)
	local a = MT.actors[name]; if not a then return end
	a.wantBreathe = { f = f or 1, amp = amp or 1 }
end

-- MT.actSeq(name, f, seq, blendFrames): smoothly cross-fade through a sequence of acting clips in one shot
--   e.g. MT.actSeq("me", f, { {1, "think"}, {18, "shock"}, {34, "panic"} }, 6)
function MT.actSeq(name, f, seq, blendFrames)
	local a = MT.actors[name]; if not a or not seq or #seq == 0 then return end
	local bf = blendFrames or 5
	local curIdx = 1
	for i = 1, #seq do
		if f >= seq[i][1] then curIdx = i end
	end
	local cur = seq[curIdx]
	if curIdx > 1 and (f - cur[1]) < bf then
		local prev = seq[curIdx - 1]
		local alpha = clamp((f - cur[1]) / bf, 0, 1)
		MT.actPose(name, prev[2], f, prev[1], { weight = 1 })
		MT.actPose(name, cur[2], f, cur[1], { weight = alpha })
	else
		MT.actPose(name, cur[2], f, cur[1], { weight = 1 })
	end
end

-- MT.talkGesture(name, f, speaking): natural subtle hand & head gestures while speaking (driven by words.json)
function MT.talkGesture(name, f, speaking)
	local a = MT.actors[name]; if not a then return end
	a.wantTalkGesture = { f = f or 1, active = speaking ~= false }
end

-- Allow MT.anim(name, "panic", f0, speed) to seamlessly invoke MT.ACTING clips too!
local animBase = MT.anim12Base or MT.anim
MT.anim12Base = animBase
function MT.anim(name, clip, f0, speed)
	if MT.ACTING[clip] and not MT.R6ANIM[clip] then
		local a = MT.actors[name]
		if a then
			a.wantAct = { clip = clip, f0 = f0 or 1, speed = speed or 1 }
		end
		return
	end
	animBase(name, clip, f0, speed)
end

local UPPER_JOINTS = { head = true, armL = true, armR = true }

local function applyPoseTable(joints, pose, weight, upperOnly, additive)
	for k, spec in pairs(pose) do
		if (not upperOnly) or UPPER_JOINTS[k] then
			local j = joints[k]
			if j then
				local rx, ry, rz, off = spec[1] or 0, spec[2] or 0, spec[3] or 0, spec[4]
				local tf = localTransform(j, rx, ry, rz, off)
				if additive then
					j.Transform = j.Transform * CFrame.identity:Lerp(tf, weight)
				elseif weight >= 0.999 then
					j.Transform = tf
				else
					j.Transform = j.Transform:Lerp(tf, weight)
				end
			end
		end
	end
end

local function applyLookAt(a, joints, spec)
	local targetPos
	if spec.target == "camera" then
		targetPos = workspace.CurrentCamera.CFrame.Position
	elseif type(spec.target) == "string" then
		local other = MT.actors[spec.target]
		if other and other.head then targetPos = other.head.Position end
	elseif type(spec.target) == "table" then
		targetPos = MT.V(spec.target[1], spec.target[2], spec.target[3] or 4.5)
	end
	if not targetPos or not a.head then return end
	local rel = a.root.CFrame:PointToObjectSpace(targetPos)
	local distXZ = math.sqrt(rel.X * rel.X + rel.Z * rel.Z)
	if distXZ < 0.05 then return end
	-- In Roblox character space: -Z is forward, +X is right, +Y is up
	local yaw = math.deg(math.atan2(-rel.X, -rel.Z))
	local pitch = math.deg(math.atan2(rel.Y - 1.5 * a.scale, distXZ))
	yaw = clamp(yaw, -65, 65) * (spec.weight or 1)
	pitch = clamp(pitch, -35, 35) * (spec.weight or 1)
	if joints.head then
		joints.head.Transform = joints.head.Transform * localTransform(joints.head, pitch, yaw * 0.8, 0)
	end
	if joints.root then
		joints.root.Transform = joints.root.Transform * localTransform(joints.root, 0, yaw * 0.2, 0)
	end
end

-- Hook into MT.frame (runs after lib10's stepActors & lib11's camera shake/flash)
local frame12Base = MT.frame12Base or MT.frame
MT.frame12Base = frame12Base
function MT.frame(id, f)
	for _, a in pairs(MT.actors) do
		a.actLayers = nil
		a.wantAct = nil
		a.wantLookAt = nil
		a.wantBreathe = nil
		a.wantTalkGesture = nil
	end
	frame12Base(id, f)
	local def = MT.SHOTS[id]
	for name, a in pairs(MT.actors) do
		local joints = getJoints(a)
		if a.wantAct then
			local t = math.max(0, (f - a.wantAct.f0) / 30 * (a.wantAct.speed or 1))
			local pose = MT.ACTING[a.wantAct.clip](t)
			applyPoseTable(joints, pose, 1, false, false)
		end
		if a.actLayers then
			for _, layer in ipairs(a.actLayers) do
				local o = layer.opts
				local t = math.max(0, ((layer.f or f) - layer.f0) / 30 * (o.speed or 1))
				local pose = MT.ACTING[layer.clip](t)
				applyPoseTable(joints, pose, o.weight or 1, o.upperOnly == true, o.additive == true)
			end
		end
		if a.wantTalkGesture and a.wantTalkGesture.active then
			local lip = MT.LIPSYNC and MT.LIPSYNC[id]
			local isTalking = (def and def.speak == name) and (not lip or lip:sub(f, f) == "1")
			if isTalking then
				local gt = (a.wantTalkGesture.f or f) / 30
				applyPoseTable(joints, {
					head = { sin(gt * 9.5) * 4, sin(gt * 5.2) * 5, sin(gt * 6.8) * 3 },
					armR = { 26 + sin(gt * 11) * 14, 10, -12 - cos(gt * 8) * 6 },
					armL = { 18 + cos(gt * 9) * 10, -8, 10 + sin(gt * 7) * 5 },
				}, 0.65, true, true)
			end
		end
		if a.wantBreathe then
			local bt = (a.wantBreathe.f or f) / 30
			local amp = a.wantBreathe.amp or 1
			local s = sin(bt * 2.4) * amp
			applyPoseTable(joints, {
				root = { s * 0.9, 0, 0, { 0, s * 0.025, 0 } },
				armL = { 0, 0, s * 1.4 },
				armR = { 0, 0, -s * 1.4 },
			}, 1, false, true)
		end
		if a.wantLookAt then
			applyLookAt(a, joints, a.wantLookAt)
		end
	end
end

function MT.listActing()
	local names = {}
	for k in pairs(MT.ACTING) do table.insert(names, k) end
	table.sort(names)
	return table.concat(names, ", ")
end

return "lib12 loaded (19 R6 acting clips + layering + lookAt + registerAnim)"
