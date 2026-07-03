# Video Learning Workbench

把英文视频、网页文章和博主作品，变成可以直接学习的中文资料。

它不是一个普通字幕工具。它会先听真实视频声音，再生成中文成片、中文文章或深度拉片笔记。

## 能做什么

| 你给它 | 它给你 |
|---|---|
| 英文视频链接或本地视频 | 中文硬字幕 MP4 |
| 英文网页文章 | 中文 Markdown / HTML |
| 想学习的博主视频 | 深度拉片报告，可写入飞书表格 |

适合用来学习英文 AI 教程、海外博主拍摄节奏、剪辑结构、口播文案和选题方法。

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

## 重要说明

- 视频和模型默认只保存在本机，不会提交到 GitHub。
- 拉片会以真实视频声音为准，不用平台字幕冒充口播。
- YouTube 或 Instagram 下载失败时，把视频手动下载到本机，再让 Codex / Claude 继续处理。

更完整的工作流细节见 [CLAUDE.md](CLAUDE.md)。
