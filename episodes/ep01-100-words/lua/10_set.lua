-- E01 "100 words": the cast and the sets. Look families, counters, camera helpers: studio_kit/lib11.lua.
local MT = shared.MT

---------------------------------------------------------------- cast (MT.cast / MT.kid are in lib11)
MT.CASTV = {
	jay = { shirt = "shirt_me", pants = "pants_me", hair = "hair_floof", skin = "#E8B98F", face = "neutral" },
	mom = { shirt = "shirt_mom", pants = "pants_mom", hair = "hair_brown_girl", skin = "#E8B98F", face = "smile" },
	grandpa = { shirt = "shirt_dad", pants = "pants_dad", hair = "hair_black_messy", hairColor = "#D6D6D6", skin = "#E9C3A0", face = "sad" },
	tyler = { shirt = "shirt_c1", pants = "pants_p2", hair = "hair_messy_anime", skin = "#C98F65", face = "laugh" },
	teacher = { shirt = "shirt_teacher", pants = "pants_teacher", hair = "hair_black_short", skin = "#D9A57E", face = "angry" },
	principal = { shirt = "shirt_c7", pants = "pants_p2", hair = "hair_black_messy", skin = "#A8714D", face = "smirk" },
	mayor = { shirt = "shirt_mayor", pants = "pants_mayor", skin = "#E3B58D", face = "smirk" },
}

---------------------------------------------------------------- sets (shot coords: x right, y away from camera, z up)
local function ground(col, mat) MT.box("ground", { 700, 700, 1 }, { 0, 0, -0.5 }, col or "#86C66F", { mat = mat or Enum.Material.Grass }) end

function MT.setStreet()
	ground()
	MT.box("walk", { 700, 7, 0.2 }, { 0, 3, 0.1 }, "#E4DED2", { mat = Enum.Material.Concrete })
	MT.box("road", { 700, 14, 0.12 }, { 0, 13.5, 0.06 }, "#4F5563", { mat = Enum.Material.Asphalt })
	MT.box("line", { 700, 0.35, 0.14 }, { 0, 13.5, 0.08 }, "#F5D34F")
	MT.box("walk2", { 700, 6, 0.2 }, { 0, 23.5, 0.1 }, "#E4DED2", { mat = Enum.Material.Concrete })
	MT.put("house_ca", { -38, 48, 0 }, { height = 22, rot = 180 })
	MT.put("house_cute", { 40, 46, 0 }, { height = 19, rot = 180 })
	MT.put("tree_cartoon", { -16, 33, 0 }, { height = 15 })
	MT.put("tree_cartoon", { 30, 30, 0 }, { height = 12, rot = 70 })
	MT.put("townhall", { -4, 150, 0 }, { height = 46, rot = 180 })
	-- bakery
	MT.box("bak_wall", { 15, 8, 10 }, { 12, 31, 5 }, "#F7B7A3")
	MT.box("bak_roof", { 16, 9, 0.8 }, { 12, 31, 10.2 }, "#B94A2C")
	MT.box("bak_awn", { 15.4, 2.4, 0.5 }, { 12, 25.9, 7.2 }, "#E8452C", { rot = { -14, 0, 0 } })
	MT.box("bak_win", { 9, 0.3, 4.2 }, { 12, 26.85, 3.6 }, "#BFE3F5", { refl = 0.2 })
	MT.box("bak_door", { 2.8, 0.3, 5.2 }, { 5.6, 26.85, 2.6 }, "#7A4A28")
	MT.sign("bak_sign", { "BAKERY" }, { 12, 26.7, 9.1 }, 9, 1.6, { bg = "#FFF4D6", colors = { "#B94A2C" } })
	MT.sign("bak_cards", { "YES $2", "NO $2" }, { 13, 26.6, 3.5 }, 6.4, 3.6, { bg = "#FFFFFF", border = "#F5D34F", colors = { "#24A148", "#E8452C" }, sizes = { 0.4, 0.4 } })
	-- the rule billboard
	MT.box("bb_post1", { 0.5, 0.5, 8 }, { -12.5, 26, 4 }, "#3A3F4A"); MT.box("bb_post2", { 0.5, 0.5, 8 }, { -1.5, 26, 4 }, "#3A3F4A")
	MT.sign("rule", { "WELCOME TO PIPPIN", "100 WORDS A DAY" }, { -7, 25.7, 8.6 }, 13, 4.2,
		{ bg = "#FFF8E7", border = "#2F3E63", colors = { "#2F3E63", "#E8452C" }, sizes = { 0.3, 0.44 } })
	for i, x in ipairs({ -30, -20, 20, 32 }) do
		MT.box("lamp" .. i, { 0.35, 0.35, 9 }, { x, 6.8, 4.5 }, "#3A3F4A")
		MT.box("lampHead" .. i, { 1.2, 1.2, 0.7 }, { x, 6.8, 9.2 }, "#FFF2C4", { neon = true })
	end
	-- dressing (E01 review: the street read empty)
	MT.putIf("car", { -24, 11, 0 }, { height = 5, rot = 90 }); MT.putIf("car", { 24, 16, 0 }, { height = 5, rot = -90 })
	MT.putIf("bench", { -15, 6.4, 0 }, { height = 2.6, rot = 180 })
	for i, x in ipairs({ -28, -9, 5, 21 }) do MT.putIf("bush", { x, 27.5, 0 }, { height = 2.6, rot = i * 70 }) end
	MT.putIf("fence", { -30, 27, 0 }, { width = 12 }); MT.putIf("fence", { 34, 27, 0 }, { width = 12 })
end

function MT.setKitchen()
	ground("#C99A6B", Enum.Material.WoodPlanks)
	MT.box("wall", { 44, 1, 14 }, { 0, 12, 7 }, "#F6E3BE")
	MT.box("wallL", { 1, 30, 14 }, { -16, 0, 7 }, "#F6E3BE")
	MT.box("win", { 8, 0.3, 5 }, { -5, 11.4, 7.5 }, "#A9DBF7", { neon = true, tr = 0.1 })
	MT.box("winFrame", { 8.8, 0.25, 0.5 }, { -5, 11.35, 7.5 }, "#FFFFFF")
	MT.box("counter", { 14, 3, 3.2 }, { 7, 9.8, 1.6 }, "#FAFAF7")
	MT.box("top", { 14.4, 3.4, 0.3 }, { 7, 9.8, 3.3 }, "#3A3F4A")
	MT.box("tiles", { 14, 0.2, 4 }, { 7, 11.4, 5.5 }, "#8FC9F0", { mat = Enum.Material.Glass })
	MT.box("fridge", { 4, 3, 8 }, { -12, 9.6, 4 }, "#E6EEF2")
	MT.sign("note", { "SAVE YOUR", "WORDS!" }, { -12, 8.0, 5.6 }, 2.8, 1.9, { bg = "#FFF59A", colors = { "#E8452C", "#E8452C" } })
	MT.box("pot", { 1.4, 1.4, 1 }, { 9, 9.8, 4 }, "#E8452C")
	MT.box("bowl", { 1.2, 1.2, 0.4 }, { 3, 9.8, 3.65 }, "#F5D66E")
	local l = MT.box("ceil", { 2, 2, 0.3 }, { 0, 5, 13 }, "#FFF2C4", { neon = true })
	MT.light(l, "PointLight", "#FFE2B0", 1.6, 30)
	-- dressing (E01 review: the kitchen read empty)
	MT.putIf("kitchen_cabinets", { 7, 11.2, 7.5 }, { width = 14, rot = 180 })
	MT.putIf("plant_pot", { -14.5, 4, 0 }, { height = 4 })
	MT.putIf("kitchen_table", { -9, 1, 0 }, { height = 3 })
	MT.box("shelf", { 6, 1, 0.3 }, { -5, 11.3, 11 }, "#B98A5E")
	for i = 1, 4 do MT.box("jar" .. i, { 0.7, 0.7, 1 }, { -7.2 + i * 1.2, 11.2, 11.65 }, ({ "#E8452C", "#F5D66E", "#45B5AA", "#F6A6C1" })[i]) end
end

function MT.setClass()
	ground("#B98A5E", Enum.Material.WoodPlanks)
	MT.box("wall", { 50, 1, 14 }, { 0, 14, 7 }, "#CFE8D8")
	MT.box("wallL", { 1, 34, 14 }, { -18, 0, 7 }, "#CFE8D8")
	MT.box("board", { 16, 0.4, 6 }, { 2, 13.4, 7.4 }, "#2C5E4A")
	MT.sign("boardText", { "QUIET CLASS", "SAVE YOUR WORDS" }, { 2, 13.15, 7.4 }, 15, 5.4, { bg = "#2C5E4A", colors = { "#FFFFFF", "#F5D66E" }, sizes = { 0.32, 0.32 } })
	MT.box("clock", { 1.8, 0.3, 1.8 }, { 14, 13.4, 10.5 }, "#FFFFFF")
	MT.box("bellPost", { 0.4, 0.4, 7 }, { -14, 10, 3.5 }, "#6B5B4A")
	MT.bell = MT.box("bell", { 1.6, 1.6, 1.4 }, { -14, 9.6, 7.4 }, "#F2C230", { mat = Enum.Material.Metal, shape = Enum.PartType.Ball })
	for r = 0, 1 do for c = -1, 1 do
		local x, y = c * 7 + 2, 2 + r * 5
		MT.box(("desk%d%d"):format(r, c), { 3.2, 1.8, 0.25 }, { x, y - 1.7, 2.45 }, "#F5D66E")
		MT.box(("deskL%d%d"):format(r, c), { 3, 1.6, 2.3 }, { x, y - 1.7, 1.15 }, "#D9A64B")
	end end
	local l = MT.box("ceil", { 3, 3, 0.3 }, { 0, 4, 13.6 }, "#FFFFFF", { neon = true })
	MT.light(l, "PointLight", "#FFF6E0", 1.4, 34)
	-- dressing (E01 review: the classroom read empty)
	MT.putIf("bookshelf", { 15, 13, 0 }, { height = 7, rot = 180 })
	MT.putIf("plant_pot", { -16.5, 12, 0 }, { height = 4 })
	MT.box("winL1", { 0.3, 5, 4 }, { -17.4, 2, 7.5 }, "#A9DBF7", { neon = true, tr = 0.1 })
	MT.box("winL2", { 0.3, 5, 4 }, { -17.4, -6, 7.5 }, "#A9DBF7", { neon = true, tr = 0.1 })
	for i, c in ipairs({ "#F6A6C1", "#F5D66E", "#8FC9F0" }) do MT.box("poster" .. i, { 2.4, 0.2, 3 }, { -14 + i * 3.2, 13.35, 9.8 }, c) end
end

-- Grandpa's porch. night = porch light on, summer = golden flowers
function MT.setPorch(o)
	o = o or {}
	ground()
	MT.box("path", { 3.2, 18, 0.15 }, { 0, -2, 0.08 }, "#E4DED2", { mat = Enum.Material.Concrete })
	MT.box("houseWall", { 28, 1, 15 }, { 0, 13, 7.5 }, "#8FC1E8", { mat = Enum.Material.WoodPlanks })
	MT.box("roof", { 30, 12, 1 }, { 0, 10, 15.2 }, "#7A4A28", { rot = { 10, 0, 0 } })
	MT.box("door", { 3.4, 0.4, 6.4 }, { 0, 12.4, 4.2 }, "#B94A2C")
	MT.box("winL", { 4.6, 0.3, 3.6 }, { -7, 12.4, 6 }, "#FFF2C4", { neon = o.night })
	MT.box("winR", { 4.6, 0.3, 3.6 }, { 7, 12.4, 6 }, "#FFF2C4", { neon = o.night })
	if not o.night then MT.box("winL", { 4.6, 0.3, 3.6 }, { -7, 12.35, 6 }, "#A9DBF7") ; MT.box("winR", { 4.6, 0.3, 3.6 }, { 7, 12.35, 6 }, "#A9DBF7") end
	MT.box("deck", { 18, 6, 1 }, { 0, 9.5, 0.5 }, "#C99A6B", { mat = Enum.Material.WoodPlanks })
	MT.box("step1", { 4.4, 1.4, 0.5 }, { 0, 5.8, 0.25 }, "#B98A5E", { mat = Enum.Material.WoodPlanks })
	for i, x in ipairs({ -8.6, 8.6 }) do MT.box("post" .. i, { 0.5, 0.5, 8 }, { x, 6.8, 5 }, "#FAFAF7") end
	MT.box("rail1", { 6, 0.3, 0.3 }, { -5.6, 6.8, 3 }, "#FAFAF7"); MT.box("rail2", { 6, 0.3, 0.3 }, { 5.6, 6.8, 3 }, "#FAFAF7")
	MT.box("mailbox", { 0.8, 1.4, 0.9 }, { 5, -2, 3.5 }, "#E8452C"); MT.box("mailPost", { 0.3, 0.3, 3 }, { 5, -2, 1.5 }, "#6B5B4A")
	MT.sign("mailName", { "GRANDPA JOE" }, { 5, -2.75, 3.5 }, 1.3, 0.5, { bg = "#FFFFFF", colors = { "#3A3F4A" } })
	MT.put("house_ca", { -36, 26, 0 }, { height = 20, rot = 180 })
	MT.put("tree_cartoon", { 18, 16, 0 }, { height = 15 })
	MT.put("tree_cartoon", { -17, 4, 0 }, { height = 11, rot = 120 })
	-- dressing (E01 review)
	MT.putIf("rocking_chair", { -6.6, 10.4, 1 }, { height = 3.6, rot = 200 })
	MT.putIf("bush", { -7, 5.4, 0 }, { height = 2.4 }); MT.putIf("bush", { 7, 5.4, 0 }, { height = 2.4, rot = 90 })
	MT.putIf("fence", { -16, 0, 0 }, { width = 10 }); MT.putIf("fence", { 16, 0, 0 }, { width = 10 })
	if o.summer then
		for i = 1, 14 do MT.box("flower" .. i, { 0.6, 0.6, 0.6 }, { -9 + (i * 1.37) % 18, 5 + (i * 0.7) % 1.5, 0.3 }, i % 2 == 0 and "#F6A6C1" or "#F5D66E") end
	end
	if o.night then
		local l = MT.box("porchLamp", { 0.8, 0.8, 1 }, { -3, 12.2, 8 }, "#FFE2A0", { neon = true })
		MT.light(l, "PointLight", "#FFD08A", 2.4, 22)
	end
	if o.notice then
		MT.sign("notice", { "TOWN HALL", "NOTICE" }, { 0, 12.15, 4.6 }, 2.6, 1.8, { bg = "#FFFFFF", border = "#E8452C", colors = { "#3A3F4A", "#E8452C" } })
	end
end

function MT.setTownHall()
	ground("#E4DED2", Enum.Material.Concrete)
	MT.put("townhall", { 0, 64, 0 }, { height = 32, rot = 180 })
	MT.box("steps", { 26, 6, 1.2 }, { 0, 26, 0.6 }, "#D6D2C8", { mat = Enum.Material.Concrete })
	MT.box("bannerPost1", { 0.4, 0.4, 7 }, { -6.2, 9, 3.5 }, "#3A3F4A"); MT.box("bannerPost2", { 0.4, 0.4, 7 }, { 6.2, 9, 3.5 }, "#3A3F4A")
	MT.sign("banner", { "WORDS ARE", "FOR THE YOUNG" }, { 0, 8.8, 8.9 }, 12, 3.2, { bg = "#2F3E63", border = "#F5D34F", colors = { "#FFFFFF", "#F5D34F" }, sizes = { 0.36, 0.36 } })
	MT.put("tree_cartoon", { -20, 22, 0 }, { height = 13 })
	MT.put("tree_cartoon", { 20, 22, 0 }, { height = 13, rot = 90 })
end

return "set E01 loaded"
