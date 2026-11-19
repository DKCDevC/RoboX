<#
.SYNOPSIS
Windows PowerShell replacement for checks.sh.
Usage: .\checks.ps1 s001:1 s007:20 ... -> caps\chk_sheet.jpg
#>
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force -Path "caps" | Out-Null

$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# Locate a Windows TTF font for ffmpeg drawtext (avoids Fontconfig missing-config errors)
$winDir = if ($env:WINDIR) { $env:WINDIR } else { "C:\Windows" }
$winFonts = Join-Path $winDir "Fonts"
$fontFile = @("arial.ttf", "segoeui.ttf", "tahoma.ttf", "calibri.ttf") |
    ForEach-Object { Join-Path $winFonts $_ } |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1
$fontOpt = if ($fontFile) {
    $escaped = $fontFile.Replace("\", "/").Replace(":", "\:")
    "fontfile='$escaped':"
} else {
    ""
}

$ffmpegArgs = @("-y", "-v", "error")
$fc = ""
$stackInputs = ""
$lay = @()
$i = 0

foreach ($pair in $args) {
    if ($pair -notmatch "^([^:]+):(.+)$") {
        throw "Invalid shot:frame argument '$pair'. Expected format like s001:1"
    }
    $id = $Matches[1]
    $fr = $Matches[2]

    $lua = @"
shared.MT.roll = 90
local ok, e = pcall(function() shared.MT.cur = nil; shared.MT.frame("$id", $fr) end)
task.wait(1.3)
return ok and "ok" or ("ERR " .. tostring(e))
"@
    [System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "_ck.lua"), $lua, $utf8NoBom)
    $r = & $py rb.py lua _ck.lua
    Write-Host "$id $r"
    & $py rb.py cap "caps/ck_$id.jpg" | Out-Null

    $ffmpegArgs += @("-i", "caps/ck_$id.jpg")
    $fc += "[$i`:v]crop=ih*9/16:ih,scale=300:534,drawtext=${fontOpt}text='$id':x=4:y=4:fontsize=16:fontcolor=white:box=1:boxcolor=black[v$i];"
    $stackInputs += "[v$i]"
    $col = ($i % 6) * 300
    $row = [math]::Floor($i / 6) * 534
    $lay += "${col}_${row}"
    $i++
}

if ($i -eq 0) {
    Write-Host "Usage: .\checks.ps1 s001:1 s007:20 ..."
    exit 1
}

$filter = "$fc${stackInputs}xstack=inputs=${i}:layout=$($lay -join '|'):fill=black"
$ffmpegArgs += @("-filter_complex", $filter, "-q:v", "4", "caps/chk_sheet.jpg")
& ffmpeg @ffmpegArgs
if ($LASTEXITCODE -eq 0) {
    Write-Host "sheet ok -> caps\chk_sheet.jpg"
} else {
    exit $LASTEXITCODE
}
