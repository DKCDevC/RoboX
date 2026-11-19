-- Two 1-second test shots with route C actors (lib10) and the lib11 helpers: a walk in a wide, then a wave in a close-up.
-- Frame counts come from shots.json (load.py sets MT.N); MT.shot fills idx and n.
local MT = shared.MT
MT.resetShots()

MT.CASTV.me = { shirt = "shirt_me", pants = "pants_me", hair = "hair_floof", face = "smile" }
MT.CASTV.mom = { shirt = "shirt_mom", pants = "pants_mom", hair = "hair_brown_girl", face = "neutral" }

local function set()
	MT.box("floor", { 400, 400, 1 }, { 0, 0, -0.5 }, "#CFE3B4", { mat = Enum.Material.Grass })
	MT.box("wall", { 30, 1, 10 }, { 0, 12, 5 }, "#F2D7A6")
	MT.sign("sign", { "PICTURE DAY" }, { 0, 11.4, 7.2 }, 12, 2.4)
	MT.family("mid-neutral-normal")
end

MT.shot("s001", {
	build = function()
		set()
		MT.cast("me", { -6, 3 }, 90)
		MT.cast("mom", { 4, 4 }, 0)
		return { { 0, -16, 4.2 }, { 0, 3, 3.2 }, 26 }
	end,
	act = function(f, n, t)
		MT.walkTo("me", f, 1, n, { -6, 3 }, { -1, 3 })
		MT.counter("me", 100); MT.counter("mom", 64)
	end,
})

MT.shot("s002", {
	speak = "mom",
	build = function()
		set()
		MT.cast("mom", { 0, 0 }, 0, "smile")
		return MT.camOn("mom", 4.6, 4.4, 5.0, 0.6, 30, 0.6)
	end,
	act = function(f, n, t)
		MT.anim("mom", "wave", 1); MT.counter("mom", 64)
	end,
})
return "shots: s001 s002"
