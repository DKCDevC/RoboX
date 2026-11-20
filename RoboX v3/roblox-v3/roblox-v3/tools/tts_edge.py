#!/usr/bin/env python
"""Free, natural neural TTS + exact word-level timestamps using Microsoft Edge-TTS (no API key required).

  python tools/tts_edge.py --text script.txt --out ep/audio/vo.wav --words ep/words.json
                           [--voice en-US-AndrewNeural] [--rate +10%] [--pitch +0Hz]
  python tools/tts_edge.py --list-voices

Supports designed pauses inline in your script:
  In this town, you only get 100 words. [pause 0.6] Today, I had one left.

Recommended storyteller voices:
  English (kid / young storyteller): en-US-AnaNeural, en-US-AndrewNeural, en-US-BrianNeural, en-US-GuyNeural
  Vietnamese:                        vi-VN-NamMinhNeural, vi-VN-HoaiMyNeural

Requires: pip install edge-tts (included in requirements.txt) and ffmpeg in PATH."""
import argparse, asyncio, json, os, re, subprocess, sys, tempfile, wave

PAUSE_RE = re.compile(r"\[pause[:\s]+([0-9]+(?:\.[0-9]+)?)s?\]", re.IGNORECASE)

RECOMMENDED = [
    ("en-US-AndrewNeural",  "English (US) - Warm, natural male storyteller (great for viral Shorts)"),
    ("en-US-BrianNeural",   "English (US) - Crisp, energetic young male narrator"),
    ("en-US-GuyNeural",     "English (US) - Classic YouTube/TikTok narrator"),
    ("en-US-AnaNeural",     "English (US) - Young kid voice"),
    ("en-US-AriaNeural",    "English (US) - Expressive female narrator"),
    ("vi-VN-NamMinhNeural", "Vietnamese   - Male storyteller"),
    ("vi-VN-HoaiMyNeural",  "Vietnamese   - Female storyteller"),
]


async def synth_chunk(text, voice, rate, pitch, mp3_path):
    try:
        import edge_tts
    except ImportError:
        sys.exit("edge-tts is not installed. Run: pip install edge-tts")

    try:
        comm = edge_tts.Communicate(text, voice=voice, rate=rate, pitch=pitch, boundary="WordBoundary")
    except TypeError:
        comm = edge_tts.Communicate(text, voice=voice, rate=rate, pitch=pitch)

    words = []
    with open(mp3_path, "wb") as out_f:
        async for chunk in comm.stream():
            ctype = chunk.get("type")
            if ctype == "audio":
                out_f.write(chunk["data"])
            elif ctype == "WordBoundary":
                start = round(chunk["offset"] / 10_000_000.0, 3)
                end = round((chunk["offset"] + chunk["duration"]) / 10_000_000.0, 3)
                w = (chunk.get("text") or "").strip()
                if w:
                    words.append({"word": w, "start": start, "end": end})
    return words


def mp3_to_wav(mp3_path, wav_path, sr=48000):
    subprocess.run(
        ["ffmpeg", "-y", "-v", "error", "-i", mp3_path, "-ac", "1", "-ar", str(sr), "-sample_fmt", "s16", wav_path],
        check=True,
    )


def wav_frames_and_dur(wav_path):
    with wave.open(wav_path, "rb") as w:
        params = w.getparams()
        data = w.readframes(w.getnframes())
        dur = w.getnframes() / float(w.getframerate())
    return params, data, dur


def silence_bytes(seconds, sr=48000, sampwidth=2, nchannels=1):
    n_frames = max(0, int(round(seconds * sr)))
    return b"\x00" * (n_frames * sampwidth * nchannels)


async def run_tts(text, out_wav, out_words, voice, rate, pitch):
    # Split text into alternating [text, pause_sec, text, pause_sec, ...]
    parts = PAUSE_RE.split(text.strip())
    all_words = []
    pcm_chunks = []
    offset_sec = 0.0
    sr = 48000
    wav_params = None

    with tempfile.TemporaryDirectory() as tmp:
        for idx, part in enumerate(parts):
            if idx % 2 == 1:
                # Pause marker
                psec = float(part)
                pcm_chunks.append(silence_bytes(psec, sr=sr))
                offset_sec += psec
                continue

            seg = part.strip()
            if not seg:
                continue
            mp3_p = os.path.join(tmp, f"seg_{idx}.mp3")
            wav_p = os.path.join(tmp, f"seg_{idx}.wav")
            seg_words = await synth_chunk(seg, voice, rate, pitch, mp3_p)
            mp3_to_wav(mp3_p, wav_p, sr=sr)
            params, data, dur = wav_frames_and_dur(wav_p)
            wav_params = params
            pcm_chunks.append(data)
            for w in seg_words:
                all_words.append({
                    "word": w["word"],
                    "start": round(w["start"] + offset_sec, 3),
                    "end": round(w["end"] + offset_sec, 3),
                })
            offset_sec += dur

    if not pcm_chunks or wav_params is None:
        sys.exit("no speech audio generated (empty input text?)")

    os.makedirs(os.path.dirname(os.path.abspath(out_wav)), exist_ok=True)
    with wave.open(out_wav, "wb") as out_w:
        out_w.setnchannels(1)
        out_w.setsampwidth(2)
        out_w.setframerate(sr)
        out_w.writeframes(b"".join(pcm_chunks))

    if out_words:
        os.makedirs(os.path.dirname(os.path.abspath(out_words)), exist_ok=True)
        payload = {
            "source": f"edge-tts {voice} rate={rate} pitch={pitch}",
            "words": all_words,
        }
        with open(out_words, "w", encoding="utf-8") as fh:
            json.dump(payload, fh, indent=1, ensure_ascii=False)

    wpm = (len(all_words) / (offset_sec / 60.0)) if offset_sec > 0 else 0
    print(f"edge-tts -> {out_wav} ({offset_sec:.2f} s, {len(all_words)} words, {wpm:.0f} wpm)")
    if out_words:
        print(f"words    -> {out_words}")


def main():
    ap = argparse.ArgumentParser(description="Free neural TTS + word timestamps via Edge-TTS")
    ap.add_argument("--text", help="Plain-text script file (supports [pause 0.6] markers)")
    ap.add_argument("--out", help="Output WAV path (e.g. ep/audio/vo.wav)")
    ap.add_argument("--words", help="Output words.json path (e.g. ep/words.json)")
    ap.add_argument("--voice", default="en-US-AndrewNeural", help="Edge-TTS voice name")
    ap.add_argument("--rate", default="+10%", help="Speaking rate, e.g. +10%%, +15%%, -5%%")
    ap.add_argument("--pitch", default="+0Hz", help="Pitch shift, e.g. +0Hz, +4Hz")
    ap.add_argument("--list-voices", action="store_true", help="Print recommended storyteller voices")
    args = ap.parse_args()

    if args.list_voices:
        print("Recommended Edge-TTS storyteller voices:")
        for v, desc in RECOMMENDED:
            print(f"  {v:22s} {desc}")
        return

    if not args.text or not args.out:
        ap.error("--text and --out are required (or pass --list-voices)")

    text = open(args.text, encoding="utf-8-sig").read()
    asyncio.run(run_tts(text, args.out, args.words, args.voice, args.rate, args.pitch))


if __name__ == "__main__":
    main()
