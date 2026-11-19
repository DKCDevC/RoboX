<#
.SYNOPSIS
One-shot Windows installer / environment checker for RoboX v3.
Usage:
  .\setup_windows.ps1                  # Check tools + install Python packages (opencv-python, numpy, pillow) + verify Studio MCP
  .\setup_windows.ps1 -WithBlender     # Also install Blender, uv, mcp-for-blender, and PowerShell alias
  .\setup_windows.ps1 -CheckOnly       # Audit installed tools without installing anything
#>
param(
    [switch]$WithBlender,
    [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

function Find-RealPython {
    foreach ($cmdName in @("python", "py")) {
        $cmd = Get-Command $cmdName -ErrorAction SilentlyContinue
        if ($cmd -and $cmd.Source -notlike "*\WindowsApps\*") {
            return $cmd.Source
        }
    }
    $pyDirs = Get-ChildItem "$env:LOCALAPPDATA\Programs\Python\Python*" -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending
    foreach ($d in $pyDirs) {
        $exe = Join-Path $d.FullName "python.exe"
        if (Test-Path $exe) { return $exe }
    }
    return $null
}

function Ensure-WingetPackage {
    param(
        [string]$Label,
        [string]$CheckCommand,
        [string]$WingetId
    )
    $found = Get-Command $CheckCommand -ErrorAction SilentlyContinue
    if ($found -and $found.Source -notlike "*\WindowsApps\*") {
        Write-Host "[OK] $Label -> $($found.Source)" -ForegroundColor Green
        return $true
    }
    if ($CheckOnly) {
        Write-Host "[MISSING] $Label ($WingetId)" -ForegroundColor Yellow
        return $false
    }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "[MISSING] $Label (winget not found; please install $WingetId manually)" -ForegroundColor Red
        return $false
    }
    Write-Host "[INSTALL] Installing $Label via winget ($WingetId)..." -ForegroundColor Cyan
    winget install --id $WingetId --accept-package-agreements --accept-source-agreements
    return $true
}

Write-Host "=== RoboX v3 Windows Setup ===" -ForegroundColor Cyan
Write-Host "Folder: $Root`n"

# 1. Core CLI tools: Python, Node.js, ffmpeg
$pyExe = Find-RealPython
if ($pyExe) {
    Write-Host "[OK] Python -> $pyExe" -ForegroundColor Green
} else {
    Ensure-WingetPackage -Label "Python 3.12" -CheckCommand "python" -WingetId "Python.Python.3.12" | Out-Null
    $pyExe = Find-RealPython
}

Ensure-WingetPackage -Label "Node.js LTS" -CheckCommand "node" -WingetId "OpenJS.NodeJS.LTS" | Out-Null
Ensure-WingetPackage -Label "ffmpeg" -CheckCommand "ffmpeg" -WingetId "Gyan.FFmpeg" | Out-Null

# 2. Python packages from requirements.txt
$reqFile = Join-Path $Root "requirements.txt"
if ($pyExe) {
    if ($CheckOnly) {
        & $pyExe -c "
for m in ('cv2', 'numpy', 'PIL'):
    try:
        __import__(m)
        print('[OK] python module:', m)
    except Exception:
        print('[MISSING] python module:', m)
"
    } else {
        Write-Host "`n[PIP] Installing packages from requirements.txt..." -ForegroundColor Cyan
        & $pyExe -m pip install -r $reqFile
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
} else {
    Write-Host "[WARN] Python not found in PATH yet. Restart PowerShell after installing Python, then re-run this script." -ForegroundColor Yellow
}

# 3. Ensure studio_kit runtime directories exist
foreach ($sub in @("studio_kit\queue", "studio_kit\done", "studio_kit\caps")) {
    $p = Join-Path $Root $sub
    if (-not (Test-Path $p) -and -not $CheckOnly) {
        New-Item -ItemType Directory -Force -Path $p | Out-Null
    }
}

# 4. Check Roblox Studio MCP
$localApp = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $env:USERPROFILE "AppData\Local" }
$mcpExe = Get-ChildItem (Join-Path $localApp "Roblox\Versions\version-*\StudioMCP.exe") -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName
if ($mcpExe) {
    Write-Host "[OK] Roblox Studio MCP -> $mcpExe" -ForegroundColor Green
} else {
    Write-Host "[INFO] Roblox StudioMCP.exe not found yet under $localApp\Roblox\Versions." -ForegroundColor Yellow
    Write-Host "       Install Roblox Studio and turn on: Assistant -> Manage MCP Servers -> Enable Studio as MCP server." -ForegroundColor DarkGray
}

# 5. Optional Blender + uv + mcp-for-blender
if ($WithBlender) {
    Write-Host "`n=== Optional Blender Setup ===" -ForegroundColor Cyan
    $blenderExe = Get-ChildItem "C:\Program Files\Blender Foundation\Blender*\blender.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName
    if ($blenderExe) {
        Write-Host "[OK] Blender -> $blenderExe" -ForegroundColor Green
    } else {
        Ensure-WingetPackage -Label "Blender" -CheckCommand "blender" -WingetId "BlenderFoundation.Blender" | Out-Null
        $blenderExe = Get-ChildItem "C:\Program Files\Blender Foundation\Blender*\blender.exe" -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1 -ExpandProperty FullName
    }

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        if ($CheckOnly) {
            Write-Host "[MISSING] uv" -ForegroundColor Yellow
        } else {
            Write-Host "[INSTALL] Installing uv..." -ForegroundColor Cyan
            irm https://astral.sh/uv/install.ps1 | iex
        }
    } else {
        Write-Host "[OK] uv -> $((Get-Command uv).Source)" -ForegroundColor Green
    }

    if (-not $CheckOnly -and (Get-Command uvx -ErrorAction SilentlyContinue)) {
        uvx mcp-for-blender install-addon
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            claude mcp add --env DISABLE_TELEMETRY=true blender -- uvx mcp-for-blender
        }
    }

    if (-not $CheckOnly -and $blenderExe) {
        $profileDir = Split-Path $PROFILE -Parent
        if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Force -Path $profileDir | Out-Null }
        if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Force -Path $PROFILE | Out-Null }
        $aliasLine = "Set-Alias blender `"$blenderExe`""
        $profText = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
        if ($profText -notmatch [regex]::Escape($aliasLine)) {
            Add-Content -Path $PROFILE -Value "`n$aliasLine" -Encoding UTF8
            Write-Host "[OK] Added 'blender' alias to $PROFILE" -ForegroundColor Green
        }
    }
}

Write-Host "`nDone! Next steps:" -ForegroundColor Cyan
Write-Host "  - Test script checker : python tools\script_check.py templates\script-sheet.md"
Write-Host "  - Start Studio bridge : studio_kit\start_bridge.bat"

