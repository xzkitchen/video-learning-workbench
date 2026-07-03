# Video Learning Workbench

把英文视频、网页文章和博主作品，变成可以直接学习的中文资料。

它不是一个普通字幕工具。它会先听真实视频声音，再生成中文成片、中文文章或深度拉片笔记。

## 能做什么

| 你给它 | 它给你 | 适合用来 |
|---|---|---|
| 英文视频链接或本地视频 | 中文硬字幕 MP4 | 学英文教程、访谈、课程、短视频 |
| 英文网页文章 | 中文 Markdown / HTML | 读技术文章、产品公告、长文资料 |
| 想学习的博主视频 | 深度拉片报告 / 飞书 sheet | 拆口播节奏、镜头组织、选题公式 |

### 1. 英文视频 → 中文硬字幕 MP4

把 X/Twitter、YouTube 或本地视频转成带中文硬字幕的 MP4。

- 使用本地 Whisper 模型从真实音频转写，不依赖平台字幕
- 自动生成 `en.srt`，由 Claude / Codex 翻译成 `zh.srt`
- 自动按横屏 / 竖屏拆短字幕，避免长字幕挡画面
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
- **Agent 友好**：内置 Codex Skill，Claude / Codex 可以直接调度整套工作流。
- **开源可复制**：新机器先跑 `doctor / setup`，缺什么一目了然。

## 新电脑安装

先准备好：

- macOS 电脑
- Codex 或 Claude Code

然后打开「终端」。

第一步，安装 Homebrew：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

如果它要求输入密码，就输入你的 Mac 登录密码，然后按回车。输入时屏幕上不会显示字符，这是正常的。
安装结束后继续下一步即可，后面的脚本会自动识别 Homebrew。

第二步，安装这个项目：

```bash
cd ~
git clone https://github.com/xzkitchen/video-learning-workbench.git
cd video-learning-workbench
bin/setup.sh
```

第三步，看到 `✅ 配置完成` 以后，再安装 Skill：

```bash
bin/install-skill.sh
```

第一次安装会下载本地语音模型，大约 1.6GB，会比较久。

## 安装完成后怎么用

安装完成后不会出现一个新的 App。这个项目是给 Codex / Claude 使用的工作流。

下一步：

1. 重新打开一个 Codex / Claude 新会话。
2. 打开这个项目文件夹：`~/video-learning-workbench`。
3. 直接发任务。

如果你是在别的文件夹里打开会话，就在任务里加一句：`项目目录是 ~/video-learning-workbench`。

可以这样说：

```text
用 $video-learning-workbench 把这个视频做成中文字幕成片：https://...
```

```text
用 $video-learning-workbench 对这个视频做深度拉片：https://...
```

```text
用 $video-learning-workbench 翻译这篇文章：https://...
```

## 结果在哪里

成片、字幕、文章和拉片报告都会保存在本机的：

```text
out.nosync/
```

Codex / Claude 完成任务后会告诉你具体文件路径。

## 跨设备使用

如果这个项目通过 iCloud 同步到另一台 Mac，新设备第一次接管时在项目目录执行：

```bash
bin/resume-device.sh
```

如果它提示缺依赖或模型，再执行：

```bash
bin/setup.sh
```

`models.nosync/` 和 `out.nosync/` 是每台设备本地目录，不会同步大文件。

## 重要说明

- 视频和模型默认只保存在本机，不会提交到 GitHub。
- 拉片会以真实视频声音为准，不用平台字幕冒充口播。
- 要把拉片写入飞书表格，安装完成后再执行：`bin/setup-lark-cli.sh`。
- YouTube 或 Instagram 下载失败时，把视频手动下载到本机，再让 Codex / Claude 继续处理。

更完整的工作流细节见 [WORKFLOW.md](WORKFLOW.md)。
