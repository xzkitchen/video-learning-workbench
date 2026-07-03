#!/usr/bin/env bash
# release-check.sh —— 发布前检查公开仓库边界和基本脚本有效性
# 用法: bin/release-check.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "❌ $1" >&2
  exit 1
}

echo "== 1/5 脚本语法 =="
for f in bin/*.sh skills/video-learning-workbench/scripts/*.sh; do
  bash -n "$f"
done
python3 -m py_compile bin/srt-to-md.py bin/resplit-srt.py
echo "✅ 脚本语法通过"

echo
echo "== 2/5 Skill 结构 =="
if [ -f "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" ]; then
  python3 "$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py" skills/video-learning-workbench
else
  echo "⚠️  未找到系统 quick_validate.py,跳过 Skill 校验"
fi

echo
echo "== 3/5 公开文件边界 =="
[ -f LICENSE ] || fail "缺少 LICENSE"
[ -f glossary.example.md ] || fail "缺少 glossary.example.md"
[ -f .gitignore ] || fail "缺少 .gitignore"
grep -q '^models\.nosync/' .gitignore || fail ".gitignore 未忽略 models.nosync/"
grep -q '^out\.nosync/' .gitignore || fail ".gitignore 未忽略 out.nosync/"
grep -q '^glossary\.md$' .gitignore || fail ".gitignore 未忽略 glossary.md"
echo "✅ 忽略规则存在"

echo
echo "== 4/5 敏感信息扫描 =="
SCAN_TARGETS="README.md AGENTS.md CLAUDE.md glossary.example.md bin skills LICENSE .gitignore"
if rg -n --glob '!bin/release-check.sh' "my\\.feishu\\.cn/sheets|/Users/|St2s|a4ced2cf|access_token|appSecret|client_secret" $SCAN_TARGETS; then
  fail "发现疑似个人路径、飞书链接/token 或密钥"
fi
echo "✅ 未发现常见敏感信息模式"

echo
echo "== 5/5 Git 忽略状态 =="
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git check-ignore -q models.nosync/ || fail "Git 未正确忽略 models.nosync/"
  git check-ignore -q out.nosync/ || fail "Git 未正确忽略 out.nosync/"
  git check-ignore -q glossary.md || fail "Git 未正确忽略 glossary.md"
  echo "✅ Git 忽略状态正常"
else
  echo "⚠️  当前还不是 git 仓库,跳过 git check-ignore"
fi

echo
echo "✅ 发布前检查通过"
