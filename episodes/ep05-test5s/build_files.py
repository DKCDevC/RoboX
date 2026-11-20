"""ep05-test5s: neon city, a palette taken from the story's idea (signs that read your mind). Writes shots.json and the Luau files."""
import json, os, shutil
E = r"H:\RoboX\episodes\ep05-test5s"; S = r"H:\RoboX\episodes\ep04-test5s"
for f in ("faces.lua", "cloth.lua"):
    shutil.copy(os.path.join(S, "lua", f), os.path.join(E, "lua", f))
bounds = [0, 18, 57, 107, 125, 150]          # frames at 30 fps; cuts 1 frame before: the 0.61, Last 1.93, Everyone 3.62 (and a clause cut at 125)
shots = [{"id": f"s0{i+1}", "t": round(bounds[i] / 30, 4), "end": round(bounds[i+1] / 30, 4)} for i in range(5)]
json.dump([{"scene": "S1", "shots": shots}], open(os.path.join(E, "shots.json"), "w"), indent=1)

cast = '''-- ep05-test5s CAST (stage 1)
local MT = shared.MT
MT.HD_FACE = false
MT.CASTV.me = { shirt = "shirt_c8", pants = "pants_me", hair = "hair_floof", face = "smile" }   -- the narrator, recurring hero
MT.castPreview({ "me", "kid1" }, { me = { "smile", "shocked" }, kid1 = { "oh" } })
return "cast loaded"
'''
open(os.path.join(E, "lua", "cast.lua"), "w", encoding="utf-8").write(cast)

sets = '''-- ep05-test5s SET (stage 2): a neon night street. Palette from the idea: signs that read your mind = magenta and cyan neon on near-black
-- panels over a dark violet city, warm orange windows. Textured dark ground, haze, tall buildings, hanging signs with readable text.
local MT = shared.MT
local RGB = Color3.fromRGB
local PINK, CYAN, VIOLET, WARM = RGB(255, 60, 160), RGB(40, 220, 255), RGB(150, 100, 255), RGB(255, 170, 80)
local function neonBar(name, size, loc, col) local p = MT.box(name, size, loc, col, { neon = true, shadow = false }); return p end
local function glow(part, col, range, bri) local l = Instance.new("PointLight"); l.Color = col; l.Range = range; l.Brightness = bri; l.Shadows = false; l.Parent = part end
local function neonSign(name, lines, loc, w, h, col)
	MT.sign(name, lines, loc, w, h, { bg = "#0C0612", colors = { "#" .. col:ToHex(), "#" .. col:ToHex(), "#" .. col:ToHex() } })
	local g = glow(neonBar(name .. "_top", { w + 0.5, 0.3, 0.25 }, { loc[1], loc[2] - 0.1, loc[3] + h / 2 + 0.15 }, col), col, 14, 1.6)
	neonBar(name .. "_bot", { w + 0.5, 0.3, 0.25 }, { loc[1], loc[2] - 0.1, loc[3] - h / 2 - 0.15 }, col)
end

local function neonStreet()
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
	neonSign("sign_mind", { "I READ", "YOUR MIND" }, { 0, 12, 8 }, 8, 3.0, VIOLET)
	MT.family("dark-neutral-vivid")
	-- a darker, purple-blue world: the neon has to carry the colour
	local a = game:GetService("Lighting"):FindFirstChild("Atmosphere"); if a then a.Color = RGB(150, 90, 190); a.Decay = RGB(60, 30, 110); a.Haze = 2.2; a.Density = 0.42 end
end
MT.neonStreet = neonStreet
MT.setPreview("neon", neonStreet, { cast = { { "me", { 2, -2 }, 180, "smile" }, { "kid1", { -2, 2 }, 180, "oh" } },
	cams = { wide = { { 0, -22, 6 }, { 0, 10, 6 }, 40 }, low = { { -3, -8, 1.6 }, { 1, 12, 7 }, 34 }, top = { { 0, 8, 52 }, { 0, 8.5, 0 }, 44 } } })
return "sets loaded"
'''
open(os.path.join(E, "lua", "sets.lua"), "w", encoding="utf-8").write(sets)

shotsl = '''-- ep05-test5s STORYBOARD (stage 3): 5 shots, 5.0 s, 260 wpm. Neon palette; push-ins on all, a Dutch roll on s05; readable sign props.
local MT = shared.MT
MT.resetShots()
local street = MT.neonStreet
local PINK, CYAN = Color3.fromRGB(255, 60, 160), Color3.fromRGB(40, 220, 255)

-- s01 0.00-0.60 "In this city,"  the whole street, neon on dark, the hero small in front
MT.shot("s01", {
	build = function()
		street()
		MT.cast("me", { 1.8, -6 }, 180, "smile")
		return { { 0, -16, 3.2 }, { 0, 26, 7 }, 36, push = 0.8 }
	end,
	act = function(f, n) end,
})

-- s02 0.60-1.90 "the neon signs read your mind."  the sign close, cyan/violet glow
MT.shot("s02", {
	build = function()
		street()
		return { { 1.5, 0, 6.8 }, { 0, 12, 8 }, 32, push = 0.9 }
	end,
	act = function(f, n) end,
})

-- s03 1.90-3.57 "Last night, mine said my secret."  hero looks up, the secret sign behind him
MT.shot("s03", {
	roll = function(f) return MT.rollRamp(f, 1, 50, 0, -4) end,
	portrait = { key = Color3.fromRGB(255, 80, 170), rim = Color3.fromRGB(60, 200, 255) },
	build = function()
		street()
		MT.cast("me", { 0, 4 }, 0, "scared")
		MT.sign("secret", { "I STILL SLEEP", "WITH A NIGHTLIGHT" }, { 0, -4, 8.6 }, 8.4, 2.8, { bg = "#0C0612", colors = { "#FF3C9F", "#28DCFF" } })
		return MT.camOn("me", 4.0, 4.6, 5.3, 0.9, 30, 0.8)
	end,
	act = function(f, n) MT.actPose("me", "flinch", f, 1) end,
})

-- s04 3.57-4.17 "Everyone"  the crowd turns to look
MT.shot("s04", {
	build = function()
		street()
		MT.cast("kid1", { -4, 1 }, 180, "oh"); MT.cast("kid2", { -1.4, 2 }, 180, "shocked"); MT.cast("kid3", { 1.6, 1 }, 180, "oh"); MT.cast("kid4", { 4.2, 2 }, 180, "laugh")
		return { { 0, 12, 2.6 }, { 0, 0, 3.6 }, 34, push = 0.7 }
	end,
	act = function(f, n) end,
})

-- s05 4.17-5.00 "saw it."  hero's face, shocked; Dutch roll and a soft punch
MT.shot("s05", {
	shake = function(f) return MT.punch(f, 1, 0.6, 9) end,
	roll = function(f) return MT.rollRamp(f, 1, 25, 0, 6) end,
	portrait = { key = Color3.fromRGB(255, 80, 170), rim = Color3.fromRGB(60, 200, 255) },
	build = function()
		street()
		MT.cast("me", { 0, 0 }, 0, "shocked")
		return MT.camOn("me", 3.4, 4.6, 5.0, 0.5, 28, 0.9)
	end,
	act = function(f, n) MT.actPose("me", "flinch", f, 1) end,
})
return "shots: s01 s02 s03 s04 s05"
'''
open(os.path.join(E, "lua", "shots.lua"), "w", encoding="utf-8").write(shotsl)
print("ok")
