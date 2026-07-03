# Video Learning Workbench（视频学习工作台）

把英文视频、网页文章和博主作品变成可学习、可复用的中文资料。

它不是一个普通字幕脚本，而是一套面向学习者和内容创作者的本地工作台：  
**真实语音转写 → 中文理解 → 成片/文章/拉片报告 → 可复用方法论沉淀**。

## 一眼看懂

| 你给它 | 它产出 | 解决的问题 |
|---|---|---|
| 英文视频链接或本地视频 | 中文硬字幕 MP4 | 不会因为英文听力卡住，可以直接学习课程、访谈、教程 |
| 英文网页文章 | 中文 Markdown / HTML | 把英文长文变成可读、可归档的中文资料 |
| 想学习的博主视频 | 深度拉片报告 / 飞书 sheet | 拆出口播、镜头、剪辑节奏和可复用拍摄公式 |

最厉害的地方：它不只是“翻译内容”，而是把视频变成可以反复学习的资料库。  
尤其是拉片功能，会从真实音频转写出发，把“这个博主为什么这样拍”拆成你下次可以直接照着用的模板。

## 它能做什么

### 1. 英文视频 → 中文硬字幕 MP4

把 X/Twitter、YouTube 或本地视频转成带中文硬字幕的 MP4。

- 使用本地 Whisper 模型从真实音频转写，不依赖平台字幕
- 自动生成 `en.srt`，由 Claude/Codex 翻译成 `zh.srt`
- 自动按横屏/竖屏拆短字幕，避免长字幕挡画面
- 输出可直接播放、分享、归档的中文硬字幕视频

适合：英文 AI 教程、访谈、演讲、课程、短视频学习。

### 2. 网页文章 → 中文 Markdown / HTML

把英文网页文章抓取成 Markdown，翻译后渲染为中文 HTML。

- 保留文章结构和图片链接
- 跳过导航、页脚、广告等页面杂项
- 输出 `zh.md` 和可直接打开的中文网页

适合：英文技术文章、产品公告、教程、长文资料。

### 3. 视频深度拉片 → 飞书拉片库 / 本地报告

把一个博主视频拆成“我下次怎么拍”的学习笔记。

核心不是总结内容，而是拆出可模仿的拍摄和剪辑方法：

| 时间码 | 阶段/功能 | 中文文案 | 对应画面 | 为什么有效 | 下次怎么拍 |
|---|---|---|---|---|---|

它会强制基于真实语音转写，不靠平台字幕或画面猜口播。  
每条拉片可以写入同一个飞书表格库：**一个视频一个 sheet，以选题命名**。

适合：学习博主的开头钩子、口播节奏、镜头组织、画面动作、结尾收束和选题公式。

## 为什么值得用

- **本地优先**：模型、视频和产物都放在本机 `.nosync` 目录，不上传到第三方转写服务。
- **真实语音优先**：拉片和字幕都以视频真实音频转写为准，不拿平台字幕冒充口播。
- **学习导向**：不是只翻译“他说了什么”，而是拆“他为什么这样拍，我下次怎么照着做”。
- **Agent 友好**：内置 Codex Skill，Claude/Codex 可以直接调度整套工作流。
- **开源可复制**：新机器先跑 `doctor/setup`，缺什么一目了然。

## 快速开始

```bash
git clone https://github.com/xzkitchen/video-learning-workbench.git
cd video-learning-workbench
bin/setup.sh
```

检查环境：

```bash
bin/doctor.sh
```

安装 Codex Skill：

```bash
bin/install-skill.sh
```

开启新 Codex 会话后，可以直接用：

```text
Use $video-learning-workbench to translate this video into a Chinese hard-subtitled MP4.
Use $video-learning-workbench to create a deep lapian report for this video.
```

## 日常使用

在本目录打开 Claude Code / Codex，然后直接给它：

- 一个视频链接：输出中文硬字幕 MP4
- 一个文章链接：输出中文 Markdown / HTML
- 一个视频链接并说“拉片 / 拆解节奏 / 学习这个博主”：输出深度拉片报告，必要时写入飞书拉片库

## 手动命令

### 视频翻译

```bash
bin/1-fetch.sh "<视频链接>" <slug> [语言]
# 如果平台下载失败，手动把视频放到 out.nosync/<slug>/video.mp4 后：
bin/transcribe.sh <slug> [语言]

# Claude/Codex 翻译 out.nosync/<slug>/en.srt → zh.srt
bin/2-burn.sh <slug>
```

输出：

```text
out.nosync/<slug>/<slug>.zh.mp4
```

### 网页翻译

```bash
bin/web-fetch.sh "<文章链接>" <slug>
# Claude/Codex 翻译 out.nosync/<slug>/en.md → zh.md
bin/web-render.sh <slug>
```

输出：

```text
out.nosync/<slug>/zh.md
out.nosync/<slug>/<slug>.zh.html
```

### 深度拉片

```bash
bin/1-fetch.sh "<视频链接>" <slug> [语言]
# 或手动放 video.mp4 后：
bin/transcribe.sh <slug> [语言]

bin/3-lapian.sh <slug> [抽帧间隔秒|auto]
# Claude/Codex 翻译 speech.en.md → speech.zh.md，并填写 lapian.md
bin/lapian-render.sh <slug>
```

输出：

```text
out.nosync/<slug>/lapian/lapian.md
out.nosync/<slug>/lapian/lapian.html
```

## 脚本一览

- `bin/setup.sh`：安装依赖、下载 Whisper 模型、初始化目录
- `bin/doctor.sh`：检测本机依赖、模型、Python 库和可选飞书授权
- `bin/init-project.sh`：只初始化本地目录和个人术语表
- `bin/install-skill.sh`：安装 Codex Skill
- `bin/release-check.sh`：发布前检查脚本语法、Skill 结构、忽略规则和常见敏感信息
- `bin/1-fetch.sh` / `bin/transcribe.sh`：下载或本地视频转写
- `bin/2-burn.sh`：烧录中文硬字幕
- `bin/web-fetch.sh` / `bin/web-render.sh`：网页抓取与中文 HTML 渲染
- `bin/3-lapian.sh` / `bin/lapian-render.sh`：拉片素材包和 HTML 报告
- `skills/video-learning-workbench/`：Codex Skill

## 环境要求

第一版默认面向 macOS + Homebrew。

主要依赖：

- `yt-dlp`
- `ffmpeg-full`，需要 libass/subtitles 滤镜
- `whisper-cpp`
- Python 库：`html2text`、`markdown`
- 可选：`lark-cli`，用于写入飞书拉片库

`bin/setup.sh` 会自动安装主要依赖并下载 `ggml-large-v3-turbo` Whisper 模型。

## 隐私和开源边界

不会提交或公开：

- `models.nosync/`
- `out.nosync/`
- `glossary.md`
- 本地视频、字幕、音频、成片
- 飞书个人链接或 token

仓库只带 `glossary.example.md`，每个用户本地维护自己的 `glossary.md`。

## 注意

请遵守视频平台条款和版权要求。这个工具适合处理你有权学习、保存或转换的内容。

完整流程细节、字幕设定、多设备使用和已知坑见 [CLAUDE.md](CLAUDE.md)。
