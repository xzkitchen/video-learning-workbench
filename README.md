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

## 新电脑第一次安装

安装前需要：

- 一台 macOS 电脑
- 已安装 Homebrew；如果没有，先按 [brew.sh](https://brew.sh/) 的说明安装
- 已安装 Codex / Claude Code 这类能读取本地 Skill 的 Agent 工具

如果第一次在终端里使用 `git`、`brew` 或其他开发工具时，macOS 弹出 Command Line Tools / 开发者工具安装窗口，选择安装即可。安装窗口消失后，回到终端继续；如果刚才的命令已经中断，就重新执行一次。

先把项目放到一个固定目录：

```bash
git clone https://github.com/xzkitchen/video-learning-workbench.git
cd video-learning-workbench
```

注意：复制命令时只复制纯 URL，不要复制成 Markdown 链接格式。

正确：

```bash
git clone https://github.com/xzkitchen/video-learning-workbench.git
```

错误：

```bash
git clone [https://github.com/xzkitchen/video-learning-workbench.git](https://github.com/xzkitchen/video-learning-workbench.git)
```

然后跑初始化：

```bash
bin/setup.sh
```

这一步会安装本机依赖、初始化目录，并下载 Whisper 模型。模型大约 1.6GB，第一次会比较久。

如果安装过程中弹出系统安装窗口，窗口消失不代表这个工具打开了一个 App，它只是系统依赖装完了；回到终端，等命令继续跑到出现 `✅ 配置完成`。如果终端已经中断，重新执行：

```bash
bin/setup.sh
```

如果你看到类似下面的报错：

```text
xcode-select: note: No developer tools were found, requesting install.
cd: no such file or directory: video-learning-workbench
zsh: no such file or directory: bin/setup.sh
```

说明 `git clone` 被系统开发者工具安装流程打断了，项目还没有下载成功。等 Command Line Tools 安装完成后，重新从第一步开始：

```bash
cd ~
git clone https://github.com/xzkitchen/video-learning-workbench.git
cd video-learning-workbench
bin/setup.sh
```

确认环境没问题：

```bash
bin/doctor.sh
```

安装 Codex Skill：

```bash
bin/install-skill.sh
```

安装完成后不会出现一个单独的软件窗口。这个 Skill 的作用是让 Codex / Claude 知道“遇到视频翻译、网页翻译、拉片任务时该怎么调度这个项目”。

下一步：

1. 关闭当前 Codex / Claude 会话，重新打开一个新会话。
2. 最好在 `video-learning-workbench` 这个项目目录里打开新会话。
3. 直接把视频链接、文章链接或本地视频路径发给它，并明确点名这个 Skill。

第一次可以这样测试：

```text
Use $video-learning-workbench to translate this video into a Chinese hard-subtitled MP4.
Use $video-learning-workbench to create a deep lapian report for this video.
```

也可以直接用中文：

```text
用 $video-learning-workbench 把这个视频做成中文字幕成片：https://...
用 $video-learning-workbench 对这个视频做深度拉片：https://...
```

如果 Codex 找不到项目目录，把这句话一起发给它：

```text
项目目录是：/你的/本地路径/video-learning-workbench
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
