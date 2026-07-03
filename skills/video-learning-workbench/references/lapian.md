# Deep Lapian Workflow

## Goal

Create a practical video breakdown for learning another creator's filming, editing, script, and pacing. The output should help the user copy the underlying method, not admire abstract jargon.

## Steps

1. Fetch/transcribe exactly like video translation:

```bash
bin/1-fetch.sh "<video-url>" <slug> [language]
# or, for local/manual video:
bin/transcribe.sh <slug> [language]
```

2. Prepare lapian materials:

```bash
bin/3-lapian.sh <slug> [frame-interval|auto]
```

This creates:

- `lapian/speech.en.md`
- `lapian/speech.zh.md`
- `lapian/speech.segments.tsv`
- `lapian/frames.md`
- `lapian/lapian.md`

3. Translate real speech:

- Read `glossary.md` and `lapian/speech.en.md`.
- Fill `lapian/speech.zh.md`.
- Preserve time headings.
- Correct obvious Whisper errors and report corrections.
- Do not use platform captions as replacement speech.

4. Fill `lapian/lapian.md` with this compact structure:

```markdown
# 深度拉片：<选题名称>

## 一句话定位

## 真实口播文案

## 时间轴拉片

| 时间码 | 阶段/功能 | 中文文案 | 对应画面 | 为什么有效 | 下次怎么拍 |
|---|---|---|---|---|---|

## 可复用拍法总结（好懂版）

| 项目 | 说明 |
|---|---|

## 听写修正
```

Writing rules:

- `阶段/功能`: include a stage label such as `开头｜成品钩子`, `制作｜第一刀`, `收尾｜味觉记忆`.
- `中文文案`: translated real speech only.
- `对应画面`: short visible action chain, not a paragraph.
- `为什么有效`: explain the practical reason.
- `下次怎么拍`: write as a direct shooting reminder.
- Ignore platform watermarks, downloaded overlays, platform icons, and account UI unless clearly part of the creator's intentional edit.

5. Render local HTML:

```bash
bin/lapian-render.sh <slug>
```

## Verification

- Check `speech.en.md` came from `en.srt`.
- Spot-check 2-3 timestamps against frames or the original video.
- Confirm the final summary is readable and directly reusable.
