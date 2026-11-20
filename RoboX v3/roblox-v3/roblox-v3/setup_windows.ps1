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

function Add-UserPath {
    param([string]$Dir)
    if (-not (Test-Path $Dir)) { return }
    $cur = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = ($cur -split ";") | Where-Object { $_ -ne "" }
    if ($parts -notcontains $Dir) {
        [Environment]::SetEnvironmentVariable("Path", (($parts + $Dir) -join ";"), "User")
    }
    if (($env:Path -split ";") -notcontains $Dir) {
        $env:Path = "$Dir;$env:Path"
    }
}

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
        if (Test-Path $exe) {
            Add-UserPath $d.FullName
            Add-UserPath (Join-Path $d.FullName "Scripts")
            return $exe
        }
    }
    return $null
}

function Find-Tool {
    param([string]$CmdName, [string[]]$ExtraDirs)
    $found = Get-Command $CmdName -ErrorAction SilentlyContinue
    if ($found -and $found.Source -notlike "*\WindowsApps\*") {
        return $found.Source
    }
    foreach ($d in $ExtraDirs) {
        $exe = Join-Path $d "$CmdName.exe"
        if (Test-Path $exe) {
            Add-UserPath $d
            return $exe
        }
    }
    return $null
}

function Install-DirectFallback {
    param([string]$WingetId)
    $tmp = Join-Path $env:TEMP "robox_setup"
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null

    if ($WingetId -eq "Python.Python.3.12") {
        $url = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
        $inst = Join-Path $tmp "python-3.12.8-amd64.exe"
        Write-Host "[DOWNLOAD] Python 3.12.8..." -ForegroundColor Cyan
        & curl.exe -fL --progress-bar $url -o $inst
        if ($LASTEXITCODE -ne 0) { throw "Failed to download Python from $url" }
        Write-Host "[INSTALL] Running silent Python installer..." -ForegroundColor Cyan
        $p = Start-Process -FilePath $inst -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "Include_test=0" -Wait -PassThru
        if ($p.ExitCode -ne 0) { throw "Python installer exited with $($p.ExitCode)" }
        return $true
    }
    if ($WingetId -eq "OpenJS.NodeJS.LTS") {
        $url = "https://nodejs.org/dist/v22.11.0/node-v22.11.0-win-x64.zip"
        $zip = Join-Path $tmp "node-v22.11.0-win-x64.zip"
        $dest = Join-Path $env:LOCALAPPDATA "Programs\nodejs"
        Write-Host "[DOWNLOAD] Node.js v22 LTS..." -ForegroundColor Cyan
        & curl.exe -fL --progress-bar $url -o $zip
        if ($LASTEXITCODE -ne 0) { throw "Failed to download Node.js from $url" }
        Write-Host "[EXTRACT] Installing Node.js to $dest..." -ForegroundColor Cyan
        $extDir = Join-Path $tmp "node_ext"
        Remove-Item -Recurse -Force $extDir -ErrorAction SilentlyContinue
        & tar.exe -xf $zip -C $tmp
        $inner = Get-ChildItem $tmp -Directory -Filter "node-v*-win-x64" | Select-Object -First 1
        Remove-Item -Recurse -Force $dest -ErrorAction SilentlyContinue
        Move-Item $inner.FullName $dest
        Add-UserPath $dest
        return $true
    }
    if ($WingetId -eq "Gyan.FFmpeg") {
        $urls = @(
            "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip",
            "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        )
        $zip = Join-Path $tmp "ffmpeg.zip"
        $dest = Join-Path $env:LOCALAPPDATA "Programs\ffmpeg"
        $ok = $false
        foreach ($url in $urls) {
            Write-Host "[DOWNLOAD] FFmpeg from $url ..." -ForegroundColor Cyan
            & curl.exe -fL --speed-time 20 --speed-limit 5120 --progress-bar $url -o $zip
            if ($LASTEXITCODE -eq 0 -and (Test-Path $zip) -and (Get-Item $zip).Length -gt 10MB) {
                $ok = $true
                break
            }
            Write-Host "[WARN] Mirror slow/failed, trying next..." -ForegroundColor Yellow
        }
        if (-not $ok) { throw "Failed to download FFmpeg from all mirrors" }
        Write-Host "[EXTRACT] Installing FFmpeg to $dest..." -ForegroundColor Cyan
        $extRoot = Join-Path $tmp "ffmpeg_ext"
        Remove-Item -Recurse -Force $extRoot -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Force -Path $extRoot | Out-Null
        & tar.exe -xf $zip -C $extRoot
        $inner = Get-ChildItem $extRoot -Directory | Select-Object -First 1
        Remove-Item -Recurse -Force $dest -ErrorAction SilentlyContinue
        Move-Item $inner.FullName $dest
        Add-UserPath (Join-Path $dest "bin")
        return $true
    }
    return $false
}

function Ensure-WingetPackage {
    param(
        [string]$Label,
        [string]$CheckCommand,
        [string]$WingetId,
        [string[]]$ExtraDirs = @()
    )
    $found = Find-Tool -CmdName $CheckCommand -ExtraDirs $ExtraDirs
    if ($found) {
        Write-Host "[OK] $Label -> $found" -ForegroundColor Green
        return $true
    }
    if ($CheckOnly) {
        Write-Host "[MISSING] $Label ($WingetId)" -ForegroundColor Yellow
        return $false
    }
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[INSTALL] Installing $Label via winget ($WingetId)..." -ForegroundColor Cyan
        winget install --id $WingetId --accept-package-agreements --accept-source-agreements
        return $true
    }
    if (Install-DirectFallback -WingetId $WingetId) {
        return $true
    }
    Write-Host "[MISSING] $Label (winget not found; please install $WingetId manually)" -ForegroundColor Red
    return $false
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

Ensure-WingetPackage -Label "Node.js LTS" -CheckCommand "node" -WingetId "OpenJS.NodeJS.LTS" -ExtraDirs @("$env:LOCALAPPDATA\Programs\nodejs", "C:\Program Files\nodejs") | Out-Null
Ensure-WingetPackage -Label "ffmpeg" -CheckCommand "ffmpeg" -WingetId "Gyan.FFmpeg" -ExtraDirs @("$env:LOCALAPPDATA\Programs\ffmpeg\bin", "C:\ffmpeg\bin") | Out-Null

# 2. Python packages from requirements.txt
$reqFile = Join-Path $Root "requirements.txt"
if ($pyExe) {
    if ($CheckOnly) {
        & $pyExe -c "
for m in ('cv2', 'numpy', 'PIL', 'edge_tts'):
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

