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
echo "重启 Codex 或开启新会话后,可用 \$video-learning-workbench 调用。"
