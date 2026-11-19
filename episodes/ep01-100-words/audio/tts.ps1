# Free narration with the Windows voice (SAPI) + word timestamps.
#   powershell -ExecutionPolicy Bypass -File tts.ps1 [voice]
# Writes vo_raw.wav (48 kHz mono) and words_raw.json (word, start) next to this file.
param([string]$Voice = "Microsoft Zira Desktop")
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Speech
$here = $PSScriptRoot
$ssml = [IO.File]::ReadAllText((Join-Path $here "vo.ssml"))
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
$s.SelectVoice($Voice)
$fmt = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(48000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
$s.SetOutputToWaveFile((Join-Path $here "vo_raw.wav"), $fmt)
$script:words = New-Object System.Collections.ArrayList
$s.add_SpeakProgress({ param($sender, $e) [void]$script:words.Add([pscustomobject]@{ word = $e.Text; start = [math]::Round($e.AudioPosition.TotalSeconds, 3) }) })
$s.SpeakSsml($ssml)
$s.SetOutputToNull()
$s.Dispose()
$script:words | ConvertTo-Json | Out-File -Encoding utf8 (Join-Path $here "words_raw.json")
"words: " + $script:words.Count
