# One-time setup on Windows (all free)

Everything runs natively on Windows 10 / 11 (PowerShell). Always use `python` (not `python3`, which can trigger the Windows Store stub).

## Quick 1-click install

Double-click `setup_windows.bat`, or run in PowerShell:

```powershell
# Installs Python, Node.js, ffmpeg (if missing), and requirements.txt (opencv-python, numpy, pillow)
.\setup_windows.ps1

# Optional: also install Blender, uv, mcp-for-blender, and PowerShell alias
.\setup_windows.ps1 -WithBlender

# Check environment only (no changes)
.\setup_windows.ps1 -CheckOnly
```

---

## Manual install (if you prefer step-by-step)

### 1. Install core tools (PowerShell)

If you don't have Python 3.10+, Node.js, ffmpeg, or Blender 4.2+ yet, install them with `winget`:

```powershell
# Python & Node.js (skip if already installed)
winget install Python.Python.3.12
winget install OpenJS.NodeJS.LTS

# ffmpeg (to join rendered frames into an mp4)
winget install Gyan.FFmpeg

# Blender 4.2+ (fallback 3D renderer)
winget install BlenderFoundation.Blender
```

Install `uv` and the Blender MCP bridge (only needed if using the Blender route):

```powershell
# 1. uv (runs the Blender bridge for Claude Code)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# 2. Put the bridge add-on into Blender
uvx mcp-for-blender install-addon

# 3. Let Claude Code talk to Blender (telemetry off)
claude mcp add --env DISABLE_TELEMETRY=true blender -- uvx mcp-for-blender
```

Add a `blender` command to PowerShell (adjust version folder if you have Blender 4.2/4.3/5.x):

```powershell
# Add to your PowerShell $PROFILE (optional; skip if blender.exe is already in PATH)
$blenderExe = Get-ChildItem "C:\Program Files\Blender Foundation\Blender*\blender.exe" | Select-Object -Last 1 -ExpandProperty FullName
if ($blenderExe) {
    Add-Content $PROFILE "`nSet-Alias blender `"$blenderExe`""
    . $PROFILE
}
```

Then in Blender: **Edit → Preferences → Add-ons →** turn on **MCP for Blender**.
In the 3D view press `N` → **MCP for Blender** tab → **Start server**. Tick **Poly Haven**.
Leave the telemetry box off. Do not sign up for Premium.

## 2. Roblox Studio MCP (main route)

1. Open Roblox Studio (any Baseplate place).
2. **Assistant → … → Manage MCP Servers →** turn on **Enable Studio as MCP server**.
3. **Assistant Settings → MCP Servers → Quick connect → Claude Code** (or run the manual command in `templates\mcp-setup.md`).
4. To run batch renders with `studio_kit\`, double-click `studio_kit\start_bridge.bat` (keep the console window open). `bridge.mjs` auto-discovers `%LOCALAPPDATA%\Roblox\Versions\version-*\StudioMCP.exe`.

## 3. Python packages for the helper tools

```powershell
python -m pip install -r requirements.txt
```

## 4. Test the Blender kit

```powershell
cd "<your project folder>\skills\roblox-v3"
blender -b -P shots\example_shot.py -- draft still
explorer renders\example_shot
```

You should see 3 pictures: the hero walking in, then scared close-ups.
