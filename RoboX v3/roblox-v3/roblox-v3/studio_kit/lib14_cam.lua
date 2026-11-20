-- lib14_cam: Cinematic Camera, Dynamic DoF Tracking & Lighting Transitions (auto-loaded after lib13_sets.lua).
-- Adds:
--   MT.dollyZoom(id, f, fov0, fov1)      -- Hitchcock "Vertigo" effect for twist/shock reveals
--   MT.orbit(target, f, n, deg0, deg1, dist, height, lens) -- smooth 3D orbit around a character or point
--   MT.handheld(f, amp)                  -- organic documentary-style handheld camera float (smoother than raw shake)
--   MT.twoShot(nameA, nameB, bias, dist, lens) -- over-the-shoulder / 2-character dialogue framing
--   MT.trackDof(name)                    -- auto-focus DepthOfField on a moving actor's head every frame
--   MT.sunRays(intensity, spread)        -- volumetric sun shafts
--   MT.twistGrade(f, f0, f1, toSat, toTint) -- smooth color shift inside a single twist shot
local MT = shared.MT
local Lighting = game:GetService("Lighting")
local rad, tan, clamp, sin, cos = math.rad, math.tan, math.clamp, math.sin, math.cos

-- 1. Auto-focus DepthOfField on a moving actor (prevents out-of-focus blur during MT.runAt / MT.walkTo)
function MT.trackDof(name)
	MT._dofTarget = name
end

-- 2. Volumetric SunRays helper
function MT.sunRays(intensity, spread)
	local sr = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect", Lighting)
	sr.Enabled = true
	sr.Intensity = intensity or 0.08
	sr.Spread = spread or 0.55
	return sr
end

-- 3. Smooth color shift inside a twist shot (lerps saturation & tint from current family values)
function MT.twistGrade(f, f0, f1, toSat, toTint, toCon)
	local cc = Lighting:FindFirstChild("MTColor"); if not cc then return end
	if not MT._baseGrade then
		MT._baseGrade = { sat = cc.Saturation, con = cc.Contrast, tint = cc.TintColor }
	end
	local p = clamp((f - (f0 or 1)) / math.max(1, (f1 or 20) - (f0 or 1)), 0, 1)
	p = p * p * (3 - 2 * p)
	if toSat then cc.Saturation = MT._baseGrade.sat + (toSat - MT._baseGrade.sat) * p end
	if toCon then cc.Contrast = MT._baseGrade.con + (toCon - MT._baseGrade.con) * p end
	if toTint then
		local tcol = type(toTint) == "string" and MT.C(toTint) or toTint
		cc.TintColor = MT._baseGrade.tint:Lerp(tcol, p)
	end
end

-- 4. Hitchcock Dolly Zoom (keeps subject size constant while background warps dramatically)
function MT.dollyZoom(f, n, fov0, fov1)
	local cam = workspace.CurrentCamera
	local cb = MT.camBase; if not cb then return end
	local p = clamp((f - 1) / math.max(1, (n or 30) - 1), 0, 1)
	p = 1 - (1 - p) ^ 2
	fov0 = fov0 or cb[3] or 50
	fov1 = fov1 or 24
	local fov = fov0 + (fov1 - fov0) * p
	local camPos = MT.V(cb[1][1], cb[1][2], cb[1][3])
	local lookPos = MT.V(cb[2][1], cb[2][2], cb[2][3])
	local baseDist = (camPos - lookPos).Magnitude
	local newDist = baseDist * (tan(rad(fov0 / 2)) / tan(rad(fov / 2)))
	local dir = (camPos - lookPos).Unit
	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = fov
	cam.CFrame = CFrame.lookAt(lookPos + dir * newDist, lookPos)
end

-- 5. Smooth 3D orbit around an actor or {x, y, z} point
function MT.orbit(target, f, n, deg0, deg1, dist, height, lens)
	local lookPos
	if type(target) == "string" then
		local a = MT.actors[target]
		if a then lookPos = a.pos + Vector3.new(0, 4.2 * a.scale, 0) end
	elseif type(target) == "table" then
		lookPos = MT.V(target[1], target[2], target[3] or 4.2)
	end
	if not lookPos then return end
	local p = clamp((f - 1) / math.max(1, (n or 30) - 1), 0, 1)
	p = p * p * (3 - 2 * p)
	local ang = rad((deg0 or -25) + ((deg1 or 25) - (deg0 or -25)) * p)
	dist = dist or 6.5
	local camPos = lookPos + Vector3.new(sin(ang) * dist, height or -0.4, cos(ang) * dist)
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = lens or 36
	cam.CFrame = CFrame.lookAt(camPos, lookPos)
end

-- 6. Over-the-shoulder / 2-character dialogue framing (returns cam table for build())
function MT.twoShot(nameA, nameB, bias, dist, lens)
	local a = MT.actors[nameA]; local b = MT.actors[nameB]
	if not a or not b then return end
	local pa = a.base.pos + Vector3.new(0, 4.3 * a.scale, 0)
	local pb = b.base.pos + Vector3.new(0, 4.3 * b.scale, 0)
	local mid = pa:Lerp(pb, 0.5)
	local dir = (pb - pa)
	if dir.Magnitude < 0.05 then dir = Vector3.new(0, 0, 1) else dir = dir.Unit end
	local side = Vector3.new(-dir.Z, 0, dir.X) * (bias or 1)
	local cam = pa - dir * (dist or 4.2) + side * 2.2 + Vector3.new(0, 0.35, 0)
	local function back(v) return { v.X, -v.Z, v.Y } end
	return { back(cam), back(mid:Lerp(pb, 0.35)), lens or 34 }
end

-- 7. Organic handheld camera float (apply via def.handheld = 0.35 in shot)
local function applyHandheld(f, amp)
	local t = f / 30
	local rx = amp * (0.6 * sin(t * 2.1) + 0.3 * sin(t * 5.7) + 0.1 * sin(t * 11.3))
	local ry = amp * (0.6 * cos(t * 1.7) + 0.3 * sin(t * 4.9) + 0.1 * cos(t * 9.7))
	local rz = amp * 0.4 * sin(t * 1.3)
	local cam = workspace.CurrentCamera
	cam.CFrame = cam.CFrame * CFrame.Angles(rad(rx), rad(ry), rad(rz))
end

-- Hook into MT.frame
local frame14Base = MT.frame14Base or MT.frame
MT.frame14Base = frame14Base
function MT.frame(id, f)
	if MT.cur ~= id then
		MT._dofTarget = nil
		MT._baseGrade = nil
	end
	frame14Base(id, f)
	local def = MT.SHOTS[id]
	if def and def.handheld then
		applyHandheld(f, type(def.handheld) == "number" and def.handheld or 0.35)
	end
	if MT._dofTarget then
		local a = MT.actors[MT._dofTarget]
		local dof = Lighting:FindFirstChild("MTDof")
		if a and a.head and dof and dof.Enabled then
			local d = (workspace.CurrentCamera.CFrame.Position - a.head.Position).Magnitude
			dof.FocusDistance = d
			dof.InFocusRadius = math.max(3.5, d * 0.55)
		end
	end
end

return "lib14_cam loaded (dollyZoom + orbit + twoShot + handheld + trackDof + twistGrade)"
