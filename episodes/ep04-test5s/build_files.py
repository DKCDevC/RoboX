"""One-off: assemble ep04-test5s from E03's cast and Oak Street set (a workflow test, not a new story)."""
import json, os, re, shutil
E = r"H:\RoboX\episodes\ep04-test5s"; S = r"H:\RoboX\episodes\ep03-red-crosswalk"
os.makedirs(os.path.join(E, "lua"), exist_ok=True)
for f in ("faces.lua", "cloth.lua"):
    shutil.copy(os.path.join(S, "lua", f), os.path.join(E, "lua", f))

# frames: 150 = 5.0 s. Cuts 1 frame before the first word of a phrase (words.json: the 0.65, for 1.33, Last 2.11, Everything 3.70)
bounds = [0, 19, 39, 62, 110, 150]
shots = [{"id": f"s0{i + 1}", "t": round(bounds[i] / 30, 4), "end": round(bounds[i + 1] / 30, 4)} for i in range(5)]
json.dump([{"scene": "S1", "shots": shots}], open(os.path.join(E, "shots.json"), "w"), indent=1)

src = open(os.path.join(S, "lua", "20_shots.lua"), encoding="utf-8").read().split("\n")
i0 = next(i for i, l in enumerate(src) if l.startswith("-- Helper: Crosswalk Pole"))
i1 = next(i for i, l in enumerate(src) if l.startswith("-- Elm Street Crosswalk"))
block = "\n".join(src[i0:i1])
block = re.sub(r"\tif withBus then schoolBus\(-5\.6, -24\) end\n", "", block)
sets = """-- ep04-test5s SETS (stage 2): Oak Street crosswalk, reused from ep03. Registers the set sheet previews.
local MT = shared.MT

""" + block.rstrip() + """

MT.oakStreet = oakStreet   -- shots.lua calls it

MT.setPreview("oak", function() oakStreet("green", "mid-neutral-normal", false) end, {
	cast = { { "me", { 2.6, -0.6 }, -70, "smile" }, { "brad", { -4, 0.4 }, 90, "smirk" } },
	cams = { wide = { { 0, -20, 5.5 }, { 0, 0, 3.0 }, 34 }, low = { { -4, -9, 1.6 }, { 2, 0, 3.2 }, 32 }, top = { { 0, -0.5, 40 }, { 0, 0, 0 }, 40 } },
})
return "sets loaded"
"""
open(os.path.join(E, "lua", "sets.lua"), "w", encoding="utf-8").write(sets)

cast = """-- ep04-test5s CAST (stage 1): two characters, reused from ep03 (same outfits, hair and faces).
local MT = shared.MT
MT.HD_FACE = false   -- decal faces, as in E01 / E03

MT.CASTV.me = { shirt = "shirt_c8", pants = "pants_me", hair = "hair_floof", face = "smile" }       -- the narrator
MT.CASTV.brad = { shirt = "shirt_c2", pants = "pants_p2", hair = "hair_black_messy", face = "smirk" } -- the bully

MT.castPreview({ "me", "brad" }, { me = { "smile", "scared" }, brad = { "smirk", "terrified" } })
return "cast loaded"
"""
open(os.path.join(E, "lua", "cast.lua"), "w", encoding="utf-8").write(cast)

shots = """-- ep04-test5s STORYBOARD (stage 3): 5 shots, 5.0 s, on the approved cast and set. Fast read, 248 wpm.
local MT = shared.MT
MT.resetShots()
local oak = MT.oakStreet

-- s01 0.00-0.63 "In this town,"  wide, the crosswalk and the narrator, slow push
MT.shot("s01", {
	speak = "me",
	build = function()
		oak("green", "mid-neutral-normal", false)
		MT.cast("me", { 2.6, -0.6 }, -70, "happy")
		MT.cast("brad", { -4, 0.4 }, 90, "smirk")
		return { { 0, -13, 3.6 }, { 1, 0, 3.6 }, 32, push = 0.5 }
	end,
	act = function(f, n) MT.talkGesture("me", f) end,
})

-- s02 0.63-1.30 "the crosswalk turns red"  low close on the signal, push
MT.shot("s02", {
	build = function()
		oak("red", "dark-warm-vivid", false)
		return { { 5.5, -3, 6.2 }, { 10.8, 3.6, 9.0 }, 30, push = 0.7 }
	end,
	act = function(f, n) end,
})

-- s03 1.30-2.07 "for bullies."  Brad's smirk, close, push
MT.shot("s03", {
	build = function()
		oak("green", "mid-neutral-normal", false)
		MT.cast("brad", { -1, 0.4 }, 0, "smirk")
		return MT.camOn("brad", 3.6, 4.4, 5.0, 0.6, 30, 0.6)
	end,
	act = function(f, n) MT.anim("brad", "idle", 1) end,
})

-- s04 2.07-3.67 "Last Monday, Brad stepped on it."  Brad walks onto the crosswalk, 14 studs in 1.6 s (8.8 studs/s)
MT.shot("s04", {
	build = function()
		oak("green", "mid-neutral-normal", false)
		MT.cast("brad", { -9, 0.4 }, 90, "smirk")
		return { { -2, -20, 3.6 }, { -2, 0, 3.4 }, 32, push = 0.5 }
	end,
	act = function(f, n) MT.walkTo("brad", f, 1, n, { -9, 0.4 }, { 5, 0.4 }) end,
})

-- s05 3.67-5.00 "Everything went dark."  red, dark, Brad flinches; a Dutch roll that turns 6 degrees; shake on the first frame
MT.shot("s05", {
	shake = function(f) return MT.punch(f, 1, 1.8) end,
	roll = function(f) return MT.rollRamp(f, 1, 40, 0, 6) end,
	build = function()
		oak("red", "dark-warm-vivid", false)
		MT.cast("brad", { 4, 0 }, 0, "terrified")
		MT.heroLight("brad", "#FF2424", 12, 1.8)
		return MT.camOn("brad", 3.6, 4.5, 4.9, 0, 26, 0.8)
	end,
	act = function(f, n) MT.actPose("brad", "flinch", f, 1); MT.trackDof("brad") end,
})
return "shots: s01 s02 s03 s04 s05"
"""
open(os.path.join(E, "lua", "shots.lua"), "w", encoding="utf-8").write(shots)
print("files written")
