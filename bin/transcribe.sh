#!/usr/bin/env bash
# transcribe.sh —— 对"已放好的本地视频"转写英文字幕(手动下载 / YouTube 绕过 PO token)
# 用法: 把视频放到 out.nosync/<slug>/video.mp4(或 video.<任意扩展名>),再 bin/transcribe.sh <slug>
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

SLUG="${1:?用法: bin/transcribe.sh <slug> [语言](需先把视频放到 out.nosync/<slug>/video.*)}"
LANGOPT="${2:-en}"   # 转写语言,默认 en;可传 auto / hi / ja 等
OUT="$ROOT/out.nosync/$SLUG"

# 找视频文件(排除字幕/音频中间产物)
SRC="$(ls "$OUT"/video.* 2>/dev/null | grep -viE '\.(wav|srt|ass)$' | head -1 || true)"
[ -n "$SRC" ] || { echo "❌ 没找到 $OUT/video.*,请先把下载好的视频放进去(建议命名 video.mp4)"; exit 1; }

# 确保有 video.mp4 供后续使用(非 mp4 则转封装)
if [ "$SRC" != "$OUT/video.mp4" ]; then
  echo "转封装 $SRC → video.mp4"
  "$(ff_any)" -y -loglevel error -i "$SRC" -c copy "$OUT/video.mp4" 2>/dev/null \
    || "$(ff_any)" -y -loglevel error -i "$SRC" "$OUT/video.mp4"
fi

transcribe_to_srt "$OUT" "$LANGOPT"
echo
echo "✅ 完成 → $OUT/en.srt"
echo "下一步:Claude 翻译成 zh.srt → resplit-srt.py → bin/2-burn.sh $SLUG"
