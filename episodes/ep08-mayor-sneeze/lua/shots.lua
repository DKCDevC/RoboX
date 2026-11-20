-- ep08-mayor-sneeze STORYBOARD: 8 shots, 10.0 s. The hook: rule, "You see," and the dial.
-- Emotes: MT.anim with an acting clip (shrug, think, laugh, ...) must run in act(f) every frame, because MT.frame clears it each frame.
local MT = shared.MT
MT.resetShots()
local function set() MT.square(); MT.squarePeople() end

-- s01 0.00-1.20 "In this town, the mayor is"  wide: the square, the dial, the crowd; hero shrugs
MT.shot("s01", { build = function() set(); return { { 0, -15, 4.8 }, { 0, 5, 3.4 }, 40, push = 0.8 } end,
	act = function(f) MT.anim("hero", "shrug", 1) end })
-- s02 1.20-2.30 "whoever sneezes the loudest"  the mayor close (the mayor is not an actor, so no emote)
MT.shot("s02", { build = function() set(); return { { 4.2, 5.0, 3.7 }, { 2.6, 8.0, 4.6 }, 40, push = 0.6 } end, act = function() end })
-- s03 2.30-3.30 "on January first."  the hero, shocked, thinks
MT.shot("s03", { build = function() set(); MT.actorFace("hero", "shocked"); return MT.camOn("hero", 3.2, 4.8, 5.0, 0.5, 30, 0.7) end,
	act = function(f) MT.anim("hero", "think", 1) end })
-- s04 3.30-4.90 "You see, the whole town stands in the square"  wide: kid2 nods, kid4 waves, kid5 cheers
MT.shot("s04", { build = function() set(); return { { -7, -16, 4.0 }, { 0, 4, 3.0 }, 38, push = 0.8 } end,
	act = function(f) MT.anim("kid2", "nod", 1); MT.anim("kid4", "wave", 1); MT.anim("kid5", "cheer", 1) end })
-- s05 4.90-6.50 "at noon and breathes pepper dust."  low close on the crowd: kid3 laughs, kid1 crosses arms
MT.shot("s05", { build = function() set(); return { { 3.2, -3.6, 1.2 }, { 0, 3.2, 2.6 }, 34, push = 0.9 } end,
	act = function(f) MT.anim("kid3", "laugh", 1); MT.anim("kid1", "cross_arms", 1) end })
-- s06 6.50-8.00 "A judge reads every sneeze on a brass dial"  the dial, a Dutch roll (no one in frame)
MT.shot("s06", { roll = function(f) return MT.rollRamp(f, 1, 34, 0, 4) end,
	build = function() set(); return { { -6.0, 4.6, 4.0 }, { 0, 9.2, 3.9 }, 50, push = 0.6 } end, act = function() end })
-- s07 8.00-9.35 "that goes up to 100."  the hero, scared, hugs himself; a soft punch
MT.shot("s07", { shake = function(f) return MT.punch(f, 1, 0.4, 9) end,
	build = function() set(); MT.actorFace("hero", "scared"); return MT.camOn("hero", 3.4, 4.7, 5.0, 0.4, 30, 0.6) end,
	act = function(f) MT.anim("hero", "hug_self", 1) end })
-- s08 9.35-10.00  hold on the square; the hero shakes his head
MT.shot("s08", { build = function() set(); return { { 0, -12, 4.0 }, { 0, 9, 3.4 }, 34, push = 0.9 } end,
	act = function(f) MT.anim("hero", "headshake", 1) end })
return "shots"
