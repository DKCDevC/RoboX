<#
.SYNOPSIS
Free narration with the built-in Windows voice (SAPI), with word timestamps. No credits, no internet.

  powershell -ExecutionPolicy Bypass -File tools\tts_sapi.ps1 -Ssml <episode>\audio\vo.ssml -Out <episode>
             [-Voice "Microsoft Zira Desktop"] [-Pitch 1.26] [-Tempo 1.05] [-Rate "+18%"]

Writes <Out>\audio\vo_raw.wav, <Out>\audio\vo.wav (pitched, -16 LUFS) and <Out>\words.json ({"words": [{word, start, end}]}).
- vo.ssml: <speak ...><prosody rate="+18%">line. line. <break time="800ms"/> line.</prosody></speak> (one sentence per row of the
  script sheet; a pause row = a <break>). Escape &, <, > in the text.
- Pitch: asetrate factor. 1.26 = about +4 semitones, a kid's voice from Zira; it also speeds the read up by the same factor, so
  the SAPI read can be slower than the target. Tempo: extra atempo (pitch kept). Measured 2026-11-19: Zira +18 % -> 83 s raw ->
  x1.26 x1.05 = 62.6 s, 215 wpm.
- SAPI's SpeakProgress.AudioPosition is counted at 16 kHz even when the file is 48 kHz: times are divided by 3 here.
  Word ends are estimated (start + length), so captions hold until the next word.
#>
param(
    [Parameter(Mandatory = $true)][string]$Ssml,
    [Parameter(Mandatory = $true)][string]$Out,
    [string]$Voice = "Microsoft Zira Desktop",
    [double]$Pitch = 1.26,
    [double]$Tempo = 1.05
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Speech
$audio = Join-Path $Out "audio"
New-Item -ItemType Directory -Force -Path $audio | Out-Null
$raw = Join-Path $audio "vo_raw.wav"
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
$s.SelectVoice($Voice)
$fmt = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(48000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
$s.SetOutputToWaveFile($raw, $fmt)
$script:words = New-Object System.Collections.ArrayList
$s.add_SpeakProgress({ param($sender, $e) [void]$script:words.Add(@($e.Text, $e.AudioPosition.TotalSeconds)) })
$s.SpeakSsml([IO.File]::ReadAllText((Resolve-Path $Ssml)))
$s.SetOutputToNull(); $s.Dispose()

$vo = Join-Path $audio "vo.wav"
$rate = [int](48000 * $Pitch)
& ffmpeg -y -v error -i $raw -af "asetrate=$rate,aresample=48000,atempo=$Tempo,highpass=f=90,acompressor=threshold=-18dB:ratio=3:attack=5:release=80,loudnorm=I=-16:TP=-1.5" -ar 48000 -ac 1 $vo
if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed" }
$dur = [double](& ffprobe -v error -show_entries format=duration -of csv=p=0 $vo)

$k = 1.0 / (3.0 * $Pitch * $Tempo)       # 16 kHz position -> seconds of the pitched file
$list = @()
for ($i = 0; $i -lt $script:words.Count; $i++) {
    $w = $script:words[$i][0]; $st = $script:words[$i][1] * $k
    $next = if ($i + 1 -lt $script:words.Count) { $script:words[$i + 1][1] * $k } else { $dur - 0.15 }
    $en = [math]::Max($st + 0.08, [math]::Min($next - 0.02, $st + 0.10 + 0.055 * $w.Length))
    $list += [pscustomobject]@{ word = $w; start = [math]::Round($st, 3); end = [math]::Round($en, 3) }
}
$json = [pscustomobject]@{ source = "Windows SAPI $Voice, asetrate x$Pitch, atempo x$Tempo"; words = $list } | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText((Join-Path $Out "words.json"), $json, (New-Object System.Text.UTF8Encoding($false)))
$wpm = [math]::Round($list.Count / (($list[-1].end - $list[0].start) / 60))
"vo.wav {0:N1} s, {1} words, {2} wpm -> {3}" -f $dur, $list.Count, $wpm, (Join-Path $Out "words.json")
