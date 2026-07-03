#!/usr/bin/env bash
# doctor.sh —— 检查本机是否具备运行视频翻译 / 网页翻译 / 深度拉片的环境
# 用法: bin/doctor.sh
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODEL="$ROOT/models.nosync/ggml-large-v3-turbo.bin"
FAIL=0
WARN=0

ok() { printf '✅ %s\n' "$1"; }
warn() { printf '⚠️  %s\n' "$1"; WARN=$((WARN + 1)); }
fail() { printf '❌ %s\n' "$1"; FAIL=$((FAIL + 1)); }

check_cmd() {
  local cmd="$1" label="$2" required="${3:-yes}"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$label: $(command -v "$cmd")"
  elif [ "$required" = "yes" ]; then
    fail "缺少 $label ($cmd)"
  else
    warn "缺少可选工具 $label ($cmd)"
  fi
}

echo "== 基础工具 =="
check_cmd brew "Homebrew"
check_cmd python3 "Python 3"
check_cmd curl "curl"
check_cmd yt-dlp "yt-dlp"
check_cmd whisper-cli "whisper.cpp whisper-cli"

echo
echo "== ffmpeg-full / libass =="
FF_FULL=""
if command -v brew >/dev/null 2>&1; then
  FF_FULL="$(brew --prefix ffmpeg-full 2>/dev/null)/bin/ffmpeg"
fi
if [ -x "$FF_FULL" ]; then
  ok "ffmpeg-full: $FF_FULL"
  if "$FF_FULL" -hide_banner -filters 2>/dev/null | grep -q ' subtitles '; then
    ok "libass subtitles 滤镜可用"
  else
    fail "ffmpeg-full 找到了,但 subtitles/libass 滤镜不可用"
  fi
else
  fail "找不到 ffmpeg-full。烧字幕需要它,请跑 bin/setup.sh"
fi

echo
echo "== Python 库 =="
PY_OUT="$(python3 - <<'PY' 2>/dev/null
missing = []
for name in ["html2text", "markdown"]:
    try:
        __import__(name)
    except Exception:
        missing.append(name)
print(",".join(missing))
PY
)" || PY_STATUS=$?
if [ "${PY_STATUS:-0}" -ne 0 ]; then
  fail "Python 无法正常运行"
else
  if [ -n "$PY_OUT" ]; then
    fail "缺少 Python 库: $PY_OUT"
  else
    ok "html2text / markdown 可用"
  fi
fi

echo
echo "== 本地模型与目录 =="
[ -d "$ROOT/out.nosync" ] && ok "out.nosync 已存在" || warn "out.nosync 不存在,可跑 bin/init-project.sh"
[ -d "$ROOT/models.nosync" ] && ok "models.nosync 已存在" || warn "models.nosync 不存在,可跑 bin/setup.sh"
if [ -f "$MODEL" ]; then
  SIZE="$(du -h "$MODEL" | awk '{print $1}')"
  ok "Whisper 模型已存在: $SIZE"
else
  fail "缺少 Whisper 模型: $MODEL"
fi

echo
echo "== 飞书 / Lark 可选能力 =="
if command -v lark-cli >/dev/null 2>&1; then
  ok "lark-cli: $(command -v lark-cli)"
  if LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 lark-cli auth status --json --verify >/dev/null 2>&1; then
    ok "飞书 user 授权可用"
  else
    warn "lark-cli 已安装,但飞书授权未验证。需要写入拉片库时再登录授权。"
  fi
else
  warn "未安装 lark-cli。仍可输出本地 lapian.md/html,但不能自动写飞书拉片库。"
fi

echo
if [ "$FAIL" -eq 0 ]; then
  ok "环境检查通过"
  [ "$WARN" -gt 0 ] && echo "有 $WARN 个可选项提醒,不影响核心本地流程。"
  exit 0
fi

fail "环境检查未通过: $FAIL 个必需项缺失。建议先跑 bin/setup.sh,然后重跑 bin/doctor.sh。"
exit 1
