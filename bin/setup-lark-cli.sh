#!/usr/bin/env bash
# setup-lark-cli.sh —— 安装飞书 / Lark CLI,用于可选的飞书表格写入能力
# 用法: bin/setup-lark-cli.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      export PATH="$(dirname "$candidate"):$PATH"
      break
    fi
  done
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ 未安装 Homebrew。请先完成 bin/setup.sh。"
  exit 1
fi
BREW="$(command -v brew)"

echo "== 1/3 检查 Node.js / npx =="
if ! command -v npx >/dev/null 2>&1; then
  echo "安装 Node.js..."
  "$BREW" install node
fi

echo "== 2/3 安装官方 lark-cli =="
npx --yes @larksuite/cli@latest install

NPM_PREFIX="$(npm prefix -g 2>/dev/null || true)"
[ -n "$NPM_PREFIX" ] && export PATH="$NPM_PREFIX/bin:$PATH"
hash -r 2>/dev/null || true

echo "== 3/3 验证 lark-cli =="
if ! command -v lark-cli >/dev/null 2>&1; then
  echo "❌ lark-cli 安装后仍未出现在 PATH。请重新打开终端后再试。"
  exit 1
fi

lark-cli --version

echo
echo "✅ lark-cli 已安装。"
echo
echo "下一步:配置飞书授权"
echo "  cd \"$ROOT\""
echo "  lark-cli config init --new"
echo "  lark-cli auth login --recommend"
echo "  lark-cli auth status --verify"
echo
echo "说明:授权需要在浏览器里登录飞书并确认权限。"
