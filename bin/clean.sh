#!/usr/bin/env bash
# clean.sh —— 清理原始/中间文件省本机磁盘,只保留最终成片 + 字幕
# 用法:
#   bin/clean.sh <slug>   清理某一条
#   bin/clean.sh          清理全部条目
# 安全:仅当 <slug>.zh.mp4(最终成片)已存在时,才删原始 video.mp4(否则它是唯一源,保留)。
#       audio.wav 是纯中间产物,总是可删。字幕(en/zh/zh.short.srt)很小,一律保留。
set -euo pipefail
shopt -s nullglob
source "$(dirname "$0")/_lib.sh"

clean_one() {
  local out="$1" slug; slug="$(basename "$out")"
  [ -d "$out" ] || { echo "[$slug] 跳过(无此目录)"; return; }
  echo "[$slug]"
  [ -f "$out/audio.wav" ] && { rm -f "$out/audio.wav"; echo "  删 audio.wav"; }
  if [ -f "$out/$slug.zh.mp4" ]; then
    [ -f "$out/video.mp4" ] && { rm -f "$out/video.mp4"; echo "  删 video.mp4(成片已在,原片无用)"; }
  elif [ -f "$out/video.mp4" ]; then
    echo "  保留 video.mp4(还没烧出成片,先不删)"
  fi
}

if [ $# -ge 1 ]; then
  clean_one "$ROOT/out.nosync/$1"
else
  echo "清理 out.nosync 下全部条目..."
  for d in "$ROOT"/out.nosync/*/; do clean_one "${d%/}"; done
fi

echo "✅ 清理完成。当前各条目占用:"
ents=("$ROOT"/out.nosync/*/)
if [ ${#ents[@]} -gt 0 ]; then du -sh "${ents[@]}"; else echo "  (out.nosync 为空)"; fi
