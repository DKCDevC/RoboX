-- ep08-mayor-sneeze SET: the town square at noon. Cobbles, a row of houses behind, a brass dial on a pole that reads 0 to 100.
local MT = shared.MT
local RGB = Color3.fromRGB
local function square()
	MT.family("mid-neutral-normal")
	MT.look("day", { 0.25, 0.35, 0.9 })   -- noon: the sun high in the sky, not the family's evening sun
	MT.box("plaza", { 70, 70, 0.6 }, { 0, 0, -0.3 }, RGB(214, 196, 164), { mat = Enum.Material.Cobblestone })
	local cols = { RGB(196, 110, 84), RGB(238, 226, 200), RGB(150, 170, 140), RGB(120, 128, 150) }
	for i, x in ipairs({ -22, -11, 0, 11, 22 }) do
		MT.box("house" .. i, { 9, 6, 9 }, { x, 17, 4.5 }, cols[i % 4 + 1], { mat = Enum.Material.Brick })
		MT.box("roof" .. i, { 9.6, 6.4, 1.2 }, { x, 17, 9.6 }, RGB(92, 66, 56), { mat = Enum.Material.Slate })
	end
	MT.box("dial_pole", { 0.3, 0.3, 4.0 }, { 0, 9.4, 2.0 }, RGB(190, 150, 80), { mat = Enum.Material.Metal })
	MT.box("dial_base", { 1.2, 1.2, 0.5 }, { 0, 9.4, 0.25 }, RGB(120, 100, 70), { mat = Enum.Material.Metal })
	MT.sign("dial", { "SNEEZE DIAL", "0 to 100" }, { 0, 9.2, 4.2 }, 3.6, 2.0,
		{ border = RGB(150, 100, 40), bg = "#F4E6B8", colors = { "#3A2A12", "#7A4E1A" }, sizes = { 0.42, 0.34 } })
end
-- the people: the hero (recurring), the mayor and five kids all facing the camera
local function people()
	MT.cast("hero", { -1.5, -1.2 }, MT.faceTo({ -1.5, -1.2 }, { 0, -20 }), "worried")
	for i, x in ipairs({ -8.8, -4.4, 0, 4.4, 8.8 }) do
		MT.cast("kid" .. i, { x, 3.2 }, MT.faceTo({ x, 3.2 }, { 0, -20 }), "happy")
	end
	MT.mayor({ at = { 2.6, 8.0, 1.2 }, look = { 0, -20 }, face = "stare" })
end
MT.square = square
MT.squarePeople = people
MT.setPreview("square", function() square(); people() end, {
	cams = {
		wide = { { 0, -16, 4.6 }, { 0, 5, 3.2 }, 40 },
		low = { { 5.0, -12.0, 0.9 }, { 0, 8.0, 3.2 }, 34 },
		top = { { 0, -6.0, 22 }, { 0, 6.0, 1.0 }, 56 },
	} })
return "sets"
