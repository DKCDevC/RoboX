#!/usr/bin/env python
"""The @Gneef-style hero's clothes: cream cable-knit sweater, baggy brown trousers (shirt_hero.png, pants_hero.png), fabric-textured.
  python make_hero_clothes.py <out_dir>        then copy <out_dir> to Studio's content/textures/<new folder> and map them in lua/cloth.lua"""
import sys, os, random
import numpy as np
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "make_clothes.py"), encoding="utf-8").read()
ns = {}; exec(src[:src.index("\nP = dict(")], ns)
import fabricize
out = sys.argv[1]; os.makedirs(out, exist_ok=True)
sh = ns["fabric"](ns["shirt"]("#FBF6E6", "sweater", "#FFFFFF"), seed=5, strength=0.9)
pa = ns["fabric"](ns["pants"]("#9A6A44", "#7A5238", "jeans"), seed=6, strength=1.1)
rng = np.random.default_rng(3)
fabricize.fabricize(sh, 0.035, 0.012, 0.045, 1.0, rng, "shirt_hero").save(os.path.join(out, "shirt_hero.png"))
fabricize.fabricize(pa, 0.025, 0.02, 0.14, 0.9, rng, "pants_hero").save(os.path.join(out, "pants_hero.png"))
print("wrote shirt_hero.png, pants_hero.png to", out)
