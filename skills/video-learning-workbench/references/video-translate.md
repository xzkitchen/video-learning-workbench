# Video Translation Workflow

## Inputs

Accept an X/Twitter, YouTube, Instagram, or local video. Choose a stable `slug` from the topic or filename.

The local video file does not need to be inside the repository. If the user provides an absolute local video path, work from the repository root, create `out.nosync/<slug>/`, and copy the video there as `video.mp4` before transcribing.

## Steps

1. Fetch and transcribe:

```bash
bin/1-fetch.sh "<video-url>" <slug> [language]
```

If download fails or the video is local, place it at `out.nosync/<slug>/video.mp4`, then run:

```bash
bin/transcribe.sh <slug> [language]
```

2. Translate `out.nosync/<slug>/en.srt` to `out.nosync/<slug>/zh.srt`.

Rules:

- Preserve SRT numbering and timecodes exactly.
- Never add, delete, merge, split, or reorder SRT blocks during translation.
- Replace only subtitle text lines.
- Read `glossary.md` first.
- Correct obvious Whisper term errors and report the corrections.
- Keep uncertain terms in English with a brief uncertainty note if needed.

3. Validate subtitle alignment before burning:

```bash
bin/validate-srt-alignment.py out.nosync/<slug>/en.srt out.nosync/<slug>/zh.srt
```

`bin/2-burn.sh` also runs this check automatically when `en.srt` exists. If it fails, fix `zh.srt` first.

4. Burn Chinese hard subtitles:

```bash
bin/2-burn.sh <slug>
```

5. Verify 2-3 timestamps against audio and, when present, visible source captions. Confirm Chinese subtitles render in the safe area, do not overflow badly, and key terms are correct.

6. Clean large source files only after verification if the user expects disk cleanup:

```bash
bin/clean.sh <slug>
```

## Output

Return the path:

`out.nosync/<slug>/<slug>.zh.mp4`
