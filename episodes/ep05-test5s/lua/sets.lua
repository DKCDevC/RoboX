-- ep05-test5s SET (stage 2): a neon night street. Palette from the idea: signs that read your mind = magenta and cyan neon on near-black
-- panels over a dark violet city, warm orange windows. Textured dark ground, haze, tall buildings, hanging signs with readable text.
local MT = shared.MT
local RGB = Color3.fromRGB
local PINK, CYAN, VIOLET, WARM = RGB(255, 60, 160), RGB(40, 220, 255), RGB(150, 100, 255), RGB(255, 170, 80)
local function neonBar(name, size, loc, col) local p = MT.box(name, size, loc, col, { neon = true, shadow = false }); return p end
local function glow(part, col, range, bri) local l = Instance.new("PointLight"); l.Color = col; l.Range = range; l.Brightness = bri; l.Shadows = false; l.Parent = part end
local function neonSign(name, lines, loc, w, h, col)
	local board = MT.sign(name, lines, loc, w, h, { bg = "#0C0612", colors = { "#" .. col:ToHex(), "#" .. col:ToHex(), "#" .. col:ToHex() } })
	local sg = board:FindFirstChildOfClass("SurfaceGui"); if sg then sg.LightInfluence = 0; sg.Brightness = 2 end   -- neon text lights itself (night made it navy)
	local g = glow(neonBar(name .. "_top", { w + 0.5, 0.3, 0.25 }, { loc[1], loc[2] - 0.1, loc[3] + h / 2 + 0.15 }, col), col, 14, 1.6)
	neonBar(name .. "_bot", { w + 0.5, 0.3, 0.25 }, { loc[1], loc[2] - 0.1, loc[3] - h / 2 - 0.15 }, col)
end

local function neonStreet(o)
	o = o or {}
	MT.ground({ grass = RGB(26, 22, 40), road = RGB(30, 26, 40), roadW = 16 })
	local road = MT.root():FindFirstChild("road"); if road then road.Reflectance = 0.12 end
	local rng = Random.new(7)
	for _, sd in ipairs({ -1, 1 }) do
		MT.box("walk" .. sd, { 6, 200, 0.5 }, { sd * 11, 0, 0.25 }, RGB(52, 46, 64), { mat = Enum.Material.Concrete })
		for y = -40, 120, 15 do
			local h = 16 + rng:NextInteger(0, 18)
			local bx = sd * 20
			MT.box("bld" .. sd .. y, { 12, 13, h }, { bx, y, h / 2 }, RGB(40 + rng:NextInteger(0, 14), 32, 62 + rng:NextInteger(0, 20)), { mat = Enum.Material.Concrete })
			-- lit windows on the face towards the street
			for wz = 4, h - 3, 3.4 do
				for wy = -4.5, 4.5, 3 do
					if rng:NextNumber() < 0.55 then
						local c = ({ WARM, WARM, CYAN, PINK })[rng:NextInteger(1, 4)]
						MT.box("win", { 0.2, 1.5, 1.8 }, { bx - sd * 6.05, y + wy, wz }, c, { neon = true, shadow = false })
					end
				end
			end
			-- vertical neon edge
			neonBar("edge" .. sd .. y, { 0.3, 0.3, h }, { bx - sd * 6.1, y + 6.4, h / 2 }, (rng:NextNumber() < 0.5) and PINK or CYAN)
		end
		for y = -30, 90, 24 do   -- street lamps, warm
			local b = MT.box("lampbulb" .. sd .. y, { 1, 1, 0.7 }, { sd * 8.6, y, 11 }, WARM, { neon = true, shadow = false }); glow(b, WARM, 16, 1.2)
			MT.box("lamppole" .. sd .. y, { 0.3, 0.3, 11 }, { sd * 8.6, y, 5.5 }, RGB(30, 26, 38), { mat = Enum.Material.Metal })
		end
	end
	-- hanging neon signs over the street (they face the camera: shots look along +y)
	neonSign("sign_noodles", { "NOODLES", "24 HRS" }, { -5.5, 18, 9 }, 6, 2.4, PINK)
	neonSign("sign_bots", { "BOTS" }, { 5.5, 30, 10 }, 5, 1.8, CYAN)
	if not o.noMind then neonSign("sign_mind", { "I READ", "YOUR MIND" }, { 0, 12, 8 }, 8, 3.0, VIOLET) end
	MT.family("dark-neutral-vivid")
	-- a darker, purple-blue world: the neon has to carry the colour
	local a = game:GetService("Lighting"):FindFirstChild("Atmosphere"); if a then a.Color = RGB(150, 90, 190); a.Decay = RGB(60, 30, 110); a.Haze = 2.2; a.Density = 0.42 end
end
MT.neonStreet = neonStreet
MT.setPreview("neon", neonStreet, { cast = { { "me", { 2, -2 }, 180, "smile" }, { "kid1", { -2, 2 }, 180, "oh" } },
	cams = { wide = { { 0, -22, 6 }, { 0, 10, 6 }, 40 }, low = { { -3, -8, 1.6 }, { 1, 12, 7 }, 34 }, top = { { 0, 8, 52 }, { 0, 8.5, 0 }, 44 } } })
return "sets loaded"
