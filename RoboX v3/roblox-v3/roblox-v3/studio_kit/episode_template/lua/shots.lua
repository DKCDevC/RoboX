-- Two 1-second test shots with route C actors (lib10): a walk in a wide, then a wave in a close-up.
local MT = shared.MT
MT.SHOTS = {}

local function set()
	MT.box("floor", { 400, 400, 1 }, { 0, 0, -0.5 }, "#CFE3B4", { mat = Enum.Material.Grass })
	MT.box("wall", { 30, 1, 10 }, { 0, 12, 5 }, "#F2D7A6")
	MT.sign("sign", { "PICTURE DAY" }, { 0, 11.4, 7.2 }, 12, 2.4)
	MT.look("day")
end

MT.SHOTS.s001 = {
	idx = 1, n = 30,
	build = function()
		set()
		MT.actor("me", { shirt = "shirt_me", pants = "pants_me", hair = "hair_afro", face = "smile" }, { -6, 3 }, 90)
		MT.actor("mom", { shirt = "shirt_mom", pants = "pants_mom", hair = "hair_straight", face = "neutral" }, { 4, 4 }, 0)
		return { { 0, -16, 4.2 }, { 0, 3, 3.2 }, 26 }
	end,
	act = function(f, n, t)
		MT.walkTo("me", f, 1, n, { -6, 3 }, { -1, 3 })
	end,
}

MT.SHOTS.s002 = {
	idx = 2, n = 30, speak = "mom",
	build = function()
		set()
		MT.actor("mom", { shirt = "shirt_mom", pants = "pants_mom", hair = "hair_straight", face = "smile" }, { 0, 0 }, 0)
		return MT.cuActor("mom", { dist = 4.2 })
	end,
	act = function(f, n, t)
		MT.anim("mom", "wave", 1)
	end,
}
return "shots: s001 s002"
