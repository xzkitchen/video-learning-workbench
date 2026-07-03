# Feishu / Lark Lapian Sheet Output

Use this only when the user gives a Feishu/Lark sheet URL or explicitly asks to write lapian results to Feishu.

## Library Model

Use one spreadsheet as the lapian library, normally titled:

`视频深度拉片库`

Do not create a new spreadsheet for every video. For each new video, add one new sheet named after the topic:

`中文选题名｜Original Name`

Example:

`塞内加尔洋葱炖鸡｜Poulet Yassa`

## Sheet Structure

Each video sheet should use:

- Row 1 merged across A:F: topic title only.
- Row 2 headers:
  `时间码 / 阶段/功能 / 中文文案 / 对应画面 / 为什么有效 / 下次怎么拍`
- Timeline rows below.
- A compact bottom summary titled `可复用拍法总结（好懂版）`.

Do not keep old hidden sheets, duplicate versions, bilingual field labels, or redundant report-only sections for the same video.

## Tooling

Use the lark-sheets capability when available.

Recommended operations:

- `+workbook-info` to list existing sheets.
- `+sheet-create` or `+sheet-copy` to create a new video sheet.
- `+sheet-rename` to name the sheet after the topic.
- `+cells-set` / `+csv-put` for content.
- `+sheet-info` and `+csv-get` to verify.

When creating a new video sheet, prefer copying a finished template sheet to preserve widths, colors, frozen rows, merges, and summary formatting. Then overwrite content.

## Naming

Keep names short enough for sheet tabs. If the title is long, use:

`核心中文题名｜关键原名`

Avoid dates unless the topic names collide.
