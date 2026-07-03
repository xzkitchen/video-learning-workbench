#!/usr/bin/env bash
# 1-fetch.sh —— 下载 X/YouTube 视频 + 转写英文字幕 → en.srt
# 用法: bin/1-fetch.sh "<视频链接>" <slug>
#   X 一般可直接下;YouTube 受 PO token 限制常下不了,改用:手动放视频 + bin/transcribe.sh
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

URL="${1:?用法: bin/1-fetch.sh \"<视频链接>\" <slug> [语言]}"
SLUG="${2:?用法: bin/1-fetch.sh \"<视频链接>\" <slug> [语言]}"
LANGOPT="${3:-en}"   # 转写语言,默认 en;可传 auto / hi / ja 等
OUT="$ROOT/out.nosync/$SLUG"
mkdir -p "$OUT"
require_model

echo "[1/2] 下载视频 → $OUT/video.mp4"
yt-dlp -f 'bv*+ba/b' --merge-output-format mp4 -o "$OUT/video.%(ext)s" "$URL"
# 容错:未合成出 video.mp4(单流等)时转封装一份
if [ ! -f "$OUT/video.mp4" ]; then
  src="$(ls "$OUT"/video.* | grep -viE '\.(wav|srt|ass)$' | head -1)"
  "$(ff_any)" -y -loglevel error -i "$src" -c copy "$OUT/video.mp4"
fi

echo "[2/2] 转写(语言=$LANGOPT)..."
transcribe_to_srt "$OUT" "$LANGOPT"
echo
echo "✅ 完成 → $OUT/en.srt"
echo "下一步:Claude 翻译成 zh.srt → resplit-srt.py → bin/2-burn.sh $SLUG"
