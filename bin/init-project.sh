#!/usr/bin/env bash
# init-project.sh —— 初始化本地工作目录,不安装系统依赖
# 用法: bin/init-project.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$ROOT/out.nosync" "$ROOT/models.nosync"

if [ ! -f "$ROOT/glossary.md" ]; then
  if [ -f "$ROOT/glossary.example.md" ]; then
    cp "$ROOT/glossary.example.md" "$ROOT/glossary.md"
    echo "已创建 glossary.md"
  else
    printf '# 术语表\n\n| 英文 | 中文 | 处理方式 |\n|---|---|---|\n' > "$ROOT/glossary.md"
    echo "已创建空 glossary.md"
  fi
else
  echo "glossary.md 已存在,跳过"
fi

chmod +x "$ROOT/bin/"*.sh

echo "✅ 项目目录已初始化"
