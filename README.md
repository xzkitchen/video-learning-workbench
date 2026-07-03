# Video Learning Workbench（视频学习工作台）

本地运行的视频学习工具:把英文视频转成中文硬字幕 MP4,把网页文章转成中文 HTML,或把博主视频做成基于真实语音转写的深度拉片。翻译和分析由 Claude/Codex 在会话内完成,不需要付费 API。

## 用法
日常:在本目录打开 Claude Code / Codex,**把视频链接(X/YouTube)、文章链接,或视频链接+“拉片/拆解节奏”发给它**,一条龙出成片/成文/拉片报告。

安装:
```bash
git clone https://github.com/xzkitchen/video-learning-workbench.git
cd video-learning-workbench
bin/setup.sh
```

新机器 / 新用户:
```bash
bin/setup.sh                                    # 安装依赖 + 下载本地 Whisper 模型 + 初始化目录
bin/doctor.sh                                   # 检查环境是否可用
bin/install-skill.sh                            # 可选:安装 Codex Skill,之后可用 $video-learning-workbench
```

手动跑:
```bash
bin/init-project.sh                             # 仅初始化本地 out/models/glossary,不安装系统依赖
bin/1-fetch.sh "<链接>" <slug> [语言]            # 有链接(X 可直接下);语言默认 en,可传 auto/hi/ja
# 或:把视频放到 out.nosync/<slug>/video.mp4 后  bin/transcribe.sh <slug> [语言]   # YouTube/IG 等
# → Claude 把 en.srt 译成 zh.srt
bin/2-burn.sh <slug>                            # 自动按朝向拆短 + 烧字幕 → <slug>.zh.mp4
bin/clean.sh <slug>                             # (可选)删原片省磁盘,只留成片+字幕

# —— 网页文章 ——
bin/web-fetch.sh "<文章链接>" <slug>             # 抓正文转 en.md + 提取图片URL
# → Claude 把 en.md 译成 zh.md
bin/web-render.sh <slug>                        # zh.md → 自包含中文网页 <slug>.zh.html

# —— 视频深度拉片(真实语音转写 + 翻译 + 抽帧 + 节奏拆解)——
bin/1-fetch.sh "<视频链接>" <slug> [语言]          # 或手动放 video.mp4 后 bin/transcribe.sh <slug> [语言]
bin/3-lapian.sh <slug> [抽帧间隔秒|auto]         # 默认 auto:短视频更细,长视频更省帧,生成 lapian 素材包
# → Claude/Codex 翻译 lapian/speech.en.md → speech.zh.md,再按“时间码/阶段/中文文案/对应画面/为什么有效/下次怎么拍”填写 lapian/lapian.md;若写飞书,统一写入“视频深度拉片库”,每条视频新增一个选题 sheet
bin/lapian-render.sh <slug>                     # lapian.md → lapian.html,可浏览器打开/导入飞书

```

## 脚本
- `bin/_lib.sh` — 共享库(路径 / ffmpeg / whisper 提示词 / 转写核心),改这些只动这里
- `bin/setup.sh` — 新机器一键配置
- `bin/doctor.sh` — 检测本机依赖、模型、Python 库和可选飞书授权
- `bin/init-project.sh` — 初始化本地目录和个人术语表
- `bin/install-skill.sh` — 把 `skills/video-learning-workbench` 安装到本机 Codex skills 目录
- `bin/release-check.sh` — 发布前检查脚本语法、Skill 结构、忽略规则和常见敏感信息
- `bin/1-fetch.sh` — 下载 + 转写　|　`bin/transcribe.sh` — 本地文件转写
- `bin/resplit-srt.py` — 长字幕按标点拆短(2-burn 会自动调用)　|　`bin/2-burn.sh` — 拆短+烧中文硬字幕
- `bin/clean.sh` — 删原片/中间文件省磁盘(只留成片 + 字幕)
- `bin/web-fetch.sh` — 抓网页正文转 md　|　`bin/web-render.sh` — md→自包含中文 HTML
- `bin/3-lapian.sh` — 基于真实音频转写准备拉片素材包(语音稿/中文翻译模板/抽帧/报告模板)
- `bin/srt-to-md.py` — 把 Whisper 的 `en.srt` 转成可翻译、可引用的真实语音文案
- `bin/lapian-render.sh` — 把 `lapian/lapian.md` 渲染成 `lapian/lapian.html`
- `glossary.example.md` — 可公开的术语表模板;本地会生成不提交的 `glossary.md`
- `skills/video-learning-workbench/` — Codex Skill,负责调度这套工作流

## 开源注意
- 不提交 `models.nosync/`、`out.nosync/`、`glossary.md`、本地视频、字幕、音频和飞书个人链接。
- 飞书写入是可选能力;没有 `lark-cli` 授权时,拉片仍会输出本地 `lapian.md` / `lapian.html`。
- 第一版默认面向 macOS + Homebrew。

## 细节
完整流程、字幕设定、多设备使用、踩过的坑 见 **[CLAUDE.md](CLAUDE.md)**(Claude 在本目录会自动读取它)。
