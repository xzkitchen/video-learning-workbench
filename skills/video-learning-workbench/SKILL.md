---
name: video-learning-workbench
description: Local video learning workflow for translating online videos into Chinese hard-subtitled MP4s, translating web articles into Chinese Markdown/HTML, and creating deep video breakdowns ("拉片") from real audio transcripts. Use when the user provides an X/Twitter, YouTube, Instagram, or local video and asks for translation, subtitles, transcription, lapian/breakdown/rhythm analysis, or when the user asks to set up/check/deploy this local workflow.
---

# Video Learning Workbench

Use this skill to run the repository's local scripts for three workflows:

1. Video/audio -> real speech transcript -> Chinese hard-subtitled MP4.
2. Web article -> Chinese Markdown/HTML.
3. Video -> real speech transcript -> Chinese deep lapian report, optionally written to a Feishu/Lark sheet library.

## Repository Location

Before acting, locate the tool repository. Prefer the current workspace if it contains `bin/doctor.sh`, `bin/setup.sh`, and `bin/_lib.sh`.

If the current workspace is only a video/file folder, do not ask the user to move the repository into that folder. First check common install locations:

1. `~/video-learning-workbench`
2. `~/Desktop/video-learning-workbench`
3. `~/Documents/video-learning-workbench`

Use the first location that contains `bin/doctor.sh`, `bin/setup.sh`, and `bin/_lib.sh`. Only ask the user for the repository path if none of those locations exists.

Never assume the skill folder itself contains the runnable app; the skill is the playbook, the repository is the runtime.

## First Step

For a new machine or unknown environment, run:

```bash
bin/doctor.sh
```

If required checks fail, run or recommend:

```bash
bin/setup.sh
```

See `references/setup.md` for setup and troubleshooting rules.

## Route The User Request

- Video translation / subtitles: follow `references/video-translate.md`.
- Web article translation: follow `references/web-translate.md`.
- 深度拉片 / breakdown / pacing analysis / filming rhythm: follow `references/lapian.md`.
- Feishu/Lark sheet output for lapian: follow `references/feishu-lapian.md`.

## Non-Negotiables

- Use Whisper output from the real `video.mp4` audio as the source of speech text. Do not replace it with platform subtitles, titles, descriptions, or guesses from the picture.
- Keep models and outputs under `.nosync` directories; do not package or commit them.
- Keep user-specific terms in `glossary.md`; public repos should ship `glossary.example.md`.
- If a platform download fails, ask the user to place the video at `out.nosync/<slug>/video.mp4`, then run `bin/transcribe.sh <slug> [language]`.
- For lapian, write practical notes: `时间码 / 阶段/功能 / 中文文案 / 对应画面 / 为什么有效 / 下次怎么拍`.
