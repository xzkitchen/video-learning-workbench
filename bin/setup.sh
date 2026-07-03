#!/usr/bin/env bash
# setup.sh —— 在一台新 Mac 上一键配置视频学习工作台(视频翻译 + 网页翻译 + 深度拉片)
# 跑一次:bin/setup.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "== 1/6 检查 Homebrew =="
if ! command -v brew >/dev/null 2>&1; then
  echo "❌ 未安装 Homebrew,本机依赖还不能配置。"
  echo
  echo "请先复制执行这一行:"
  echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo
  echo "Homebrew 安装完成后,回到本目录继续:"
  echo "cd \"$ROOT\""
  echo "bin/setup.sh"
  exit 1
fi

echo "== 2/6 初始化本地项目目录 =="
"$ROOT/bin/init-project.sh"

echo "== 3/6 安装工具(yt-dlp / ffmpeg-full / whisper-cpp)=="
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1
# ffmpeg-full 含 libass(烧字幕必需);whisper-cpp 提供 whisper-cli;yt-dlp 下载视频
brew install yt-dlp ffmpeg-full whisper-cpp

echo "== 4/6 安装网页翻译用的 Python 库(html2text 抓正文、markdown 出 HTML)=="
python3 -m pip install -q html2text markdown 2>/dev/null \
  || python3 -m pip install -q --break-system-packages html2text markdown

echo "== 5/6 准备 whisper 模型(本机本地,不随 iCloud 同步)=="
MODEL_DIR="$ROOT/models.nosync"
MODEL="$MODEL_DIR/ggml-large-v3-turbo.bin"
mkdir -p "$MODEL_DIR"
if [ -f "$MODEL" ]; then
  echo "模型已存在,跳过:$MODEL"
else
  echo "下载 large-v3-turbo(~1.6GB)..."
  curl -L --fail --progress-bar -o "$MODEL" \
    "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi

echo "== 6/6 设脚本可执行并验证环境 =="
chmod +x "$ROOT/bin/"*.sh
"$ROOT/bin/doctor.sh"

echo
echo "✅ 配置完成,本机已可用。"
echo
echo "下一步:"
echo "  1. 安装 Codex Skill: bin/install-skill.sh"
echo "  2. 重新打开一个 Codex / Claude 新会话,最好在本项目目录中打开"
echo "  3. 发送: 用 \$video-learning-workbench 把这个视频做成中文字幕成片: <视频链接>"
echo
echo "说明:这个项目不会启动一个单独的 App。Skill 是给 Codex / Claude 读取的工作说明和脚本调度入口。"
