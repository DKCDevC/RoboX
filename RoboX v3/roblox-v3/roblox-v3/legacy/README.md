# legacy/: retired routes (don't use unless the user asks)

Kept so nothing is lost. The current skill is one look (`../look-reference.md`) and one build route (Roblox Studio on Windows, `../studio.md`, `../pipeline.md`).

| file | what it was | replaced by |
|---|---|---|
| `blender.md`, `scripts/rbxkit.py`, `scripts/faces.py`, `shots/example_*.py` | v2 build in Blender (2026-11-14) | `studio.md` + `studio_kit/` |
| `style-toon.md`, `tools/make_caps_toon.py` | bright-toon style and its ALL-CAPS phrase captions | `look-reference.md`, `captions.md` §0 |
| `pipeline-obs-mac.md` | v1 route on a Mac: shot runner played live in Studio, OBS recording, Moon Animator, Studio Preview finishing; its Appendix A has the ShotRunner / PoseLibrary / FaceLibrary Luau | `pipeline.md` (Windows, tiled capture) |
| `tools/assemble.py` | cut OBS takes at the white slates | `studio_kit/join.py` |
| `templates/mcp-setup.md` | Studio MCP tests A–C and the 2-minute decal test for the shot-runner route | MCP setup in `SETUP.md` §2 |
| `templates/lighting-presets.lua` | mood presets (`normalDay`, `sad`, …) and `P.cleanFreeModelFx()` | `assets/lighting/reference/lighting-<family>.lua` |
| `first-test-prompt.md` | first 15 s test prompt for the OBS route | "First test" in `pipeline.md` |
