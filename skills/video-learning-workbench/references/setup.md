# Setup And Environment

## Check First

Run `bin/doctor.sh` from the repository root. It checks:

- Homebrew, Python, curl
- yt-dlp
- ffmpeg-full with libass subtitles filter
- whisper-cli
- Python packages `html2text` and `markdown`
- local Whisper model at `models.nosync/ggml-large-v3-turbo.bin`
- optional `lark-cli` authorization for Feishu output

## Install Or Repair

Run `bin/setup.sh` from the repository root. It initializes local folders, installs Homebrew dependencies, installs Python libraries, downloads the Whisper model, and reruns `bin/doctor.sh`.

Use `bin/init-project.sh` when dependencies are already installed and only local directories / `glossary.md` need to be created.

## Open-Source Hygiene

Do not commit or package:

- `models.nosync/`
- `out.nosync/`
- `glossary.md`
- local videos, subtitles, audio, or rendered outputs
- Feishu document tokens or user-specific links

Commit `glossary.example.md` instead of a personal glossary.
