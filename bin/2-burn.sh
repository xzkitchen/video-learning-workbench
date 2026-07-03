#!/usr/bin/env bash
# 2-burn.sh —— 拆短(按视频朝向自动选宽度)+ 烧中文硬字幕(仅中文)
# 用法: bin/2-burn.sh <slug>  (需 out.nosync/<slug>/ 下有 video.mp4 和 zh.srt)
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

SLUG="${1:?用法: bin/2-burn.sh <slug>}"
OUT="$ROOT/out.nosync/$SLUG"
require_ffmpeg_full
[ -f "$OUT/video.mp4" ] || { echo "❌ 缺少 $OUT/video.mp4,先跑 1-fetch.sh 或 transcribe.sh"; exit 1; }

# 有整句译文 zh.srt 就按视频朝向重新拆短:竖屏窄(16)、横屏宽(26),保证宽度合适且最新
if [ -f "$OUT/zh.srt" ] && command -v python3 >/dev/null 2>&1; then
  dims="$("$FFPROBE" -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$OUT/video.mp4" 2>/dev/null || true)"
  W="${dims%x*}"; H="${dims#*x}"
  if [[ "$W" =~ ^[0-9]+$ && "$H" =~ ^[0-9]+$ && "$H" -gt "$W" ]]; then WIDTH=16; ORI=竖屏; else WIDTH=26; ORI=横屏; fi
  echo "拆短字幕($ORI ${W}x${H},每行≤$WIDTH 全角)..."
  python3 "$ROOT/bin/resplit-srt.py" "$OUT/zh.srt" "$OUT/zh.short.srt" "$WIDTH"
fi

# 烧录用:优先拆好的短字幕,没有就用整句版
SUB="zh.srt"
[ -f "$OUT/zh.short.srt" ] && SUB="zh.short.srt"
[ -f "$OUT/$SUB" ] || { echo "❌ 缺少中文字幕($OUT/zh.srt),先让 Claude 翻译"; exit 1; }

# 进入输出目录、用裸文件名,绕开「中文/空格/冒号」路径把 subtitles 滤镜搞挂的坑
cd "$OUT"
echo "烧录中文硬字幕($SUB)→ $SLUG.zh.mp4"
"$FF_FULL" -y -loglevel error -stats -i video.mp4 \
  -vf "subtitles=$SUB:fontsdir=/System/Library/Fonts:force_style='FontName=PingFang SC,FontSize=18,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BorderStyle=1,Outline=2,Shadow=1,MarginV=26'" \
  -c:a copy "$SLUG.zh.mp4"

echo "✅ 完成 → $OUT/$SLUG.zh.mp4"
echo "   (中文若显示成方框,把 FontName 改成 Heiti SC / STHeiti 再跑)"
