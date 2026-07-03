#!/usr/bin/env bash
# install-skill.sh —— 把仓库内 Skill 安装到 Codex 本地 skills 目录
# 用法: bin/install-skill.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/skills/video-learning-workbench"
DEST_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
DEST="$DEST_ROOT/video-learning-workbench"

[ -d "$SRC" ] || { echo "❌ 缺少 $SRC"; exit 1; }
mkdir -p "$DEST_ROOT"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"

echo "✅ Skill 已安装到 $DEST"
echo
echo "下一步:"
echo "  1. 关闭当前 Codex / Claude 会话,重新打开一个新会话"
echo "  2. 最好在本项目目录中打开新会话:$ROOT"
echo "  3. 发送: 用 \$video-learning-workbench 把这个视频做成中文字幕成片: <视频链接>"
echo
echo "说明:安装 Skill 不会启动单独的 App。它只是把工作流注册给 Codex / Claude 使用。"
