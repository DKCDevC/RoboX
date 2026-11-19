-- Route C test (studio.md §3.1), about 1 minute. Needs nothing but Studio open with a place, Edit mode.
--   python rb.py lua r6_test.lua
-- Then look at the viewport (or `python rb.py cap caps/r6_test.png`): a walking R6 avatar mid-stride on a grey floor.
-- Reports: does an R6 model build in Edit mode, do the default R6 clips load, and which ANIM_MODE moves the limbs.
local Players = game:GetService("Players")
local out = {}
local function say(s) table.insert(out, s) end

local old = workspace:FindFirstChild("R6Test"); if old then old:Destroy() end
local folder = Instance.new("Folder"); folder.Name = "R6Test"; folder.Parent = workspace
local floor = Instance.new("Part"); floor.Anchored = true; floor.Size = Vector3.new(40, 1, 40); floor.Position = Vector3.new(40, 0.5, 40)   -- away from the template SpawnLocation; top at y = 1
floor.Color = Color3.fromRGB(200, 204, 210); floor.Parent = folder

-- 1. build
local ok, m = pcall(function()
	local desc = Instance.new("HumanoidDescription")       -- default body colours are black; give it skin
	local skin = Color3.fromHex("#E8B98F")
	desc.HeadColor, desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor, desc.LeftLegColor, desc.RightLegColor = skin, skin, skin, skin, skin, skin
	return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
end)
if not ok then return "FAIL build: " .. tostring(m) end
m.Name = "R6Actor"
for _, d in ipairs(m:GetDescendants()) do if d:IsA("LuaSourceContainer") then d:Destroy() end end
local hum = m:FindFirstChildOfClass("Humanoid")
local root = m:FindFirstChild("HumanoidRootPart")
m.PrimaryPart = root   -- Roblox sets Head as PrimaryPart; without this PivotTo puts the head at the root height
for _, p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = (p == root); p.CanCollide = false end end
m.Parent = folder
m:PivotTo(CFrame.new(40, 4, 40))   -- root 3 studs above the floor top: feet on the floor
say("build OK, RigType=" .. tostring(hum.RigType) .. ", parts=" .. #m:GetChildren())
local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

-- 2. clips
local IDS = { idle = 180435571, walk = 180426354, jump = 125750702, wave = 128777973, point = 128853357, cheer = 129423030, laugh = 129423131, sit = 178130996 }
local tracks = {}
for name, id in pairs(IDS) do
	local a = Instance.new("Animation"); a.AnimationId = "rbxassetid://" .. id
	local tr = animator:LoadAnimation(a)
	local t0 = os.clock()
	while tr.Length == 0 and os.clock() - t0 < 5 do task.wait() end
	tracks[name] = tr
	say(string.format("clip %-5s len=%.2f %s", name, tr.Length, tr.Length > 0 and "OK" or "NOT LOADED"))
end

-- 3. does the leg move? compare the Right Leg at two times, in both modes
local leg = m:FindFirstChild("Right Leg")
local walk = tracks.walk
local function legAt(mode, t)
	for _, tr in pairs(tracks) do tr:Stop(0) end
	animator:StepAnimations(0)
	if mode == "seek" then
		walk:Play(0, 1, 0); walk:AdjustSpeed(0); walk.TimePosition = t; animator:StepAnimations(0)
	else
		walk:Play(0, 1, 1); animator:StepAnimations(0)
		local left = t
		while left > 0 do local dt = math.min(left, 1 / 30); animator:StepAnimations(dt); left -= dt end
	end
	return leg.CFrame
end
local function angle(a, b) local _, ang = (a:Inverse() * b):ToAxisAngle(); return math.deg(math.abs(ang)) end
for _, mode in ipairs({ "seek", "step" }) do
	local okm, res = pcall(function()
		local a, b = legAt(mode, 0.0), legAt(mode, walk.Length / 4)
		return angle(a, b)
	end)
	say(string.format("mode %-4s leg swing %s", mode, okm and string.format("%.1f deg %s", res, res > 5 and "OK" or "NO MOVE") or ("ERROR " .. tostring(res))))
end

-- 4. leave it mid-stride and frame it for a look
legAt("step", walk.Length / 4)
local cam = workspace.CurrentCamera
cam.CameraType = Enum.CameraType.Scriptable
cam.CFrame = CFrame.lookAt(Vector3.new(47, 5, 31), Vector3.new(40, 3.6, 40))
say("verdict: route C works if build OK, walk/idle/wave loaded, and at least one mode says OK. Set MT.ANIM_MODE to that mode.")
return table.concat(out, "\n")
