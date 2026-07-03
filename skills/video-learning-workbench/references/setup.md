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

On a new Mac, Homebrew must be installed before `bin/setup.sh` can install dependencies. If Homebrew is missing, ask the user to run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run `bin/setup.sh` from the repository root. It initializes local folders, installs Homebrew dependencies, installs Python libraries, downloads the Whisper model, and reruns `bin/doctor.sh`.

Only run `bin/install-skill.sh` after `bin/setup.sh` finishes successfully. If the user pasted all commands at once and `setup.sh` failed, `install-skill.sh` may still have copied the Skill, but the machine is not ready until setup passes.

Use `bin/init-project.sh` when dependencies are already installed and only local directories / `glossary.md` need to be created.

## Open-Source Hygiene

Do not commit or package:

- `models.nosync/`
- `out.nosync/`
- `glossary.md`
- local videos, subtitles, audio, or rendered outputs
- Feishu document tokens or user-specific links

Commit `glossary.example.md` instead of a personal glossary.
