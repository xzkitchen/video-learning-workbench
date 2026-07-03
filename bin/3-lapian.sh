#!/usr/bin/env bash
# 3-lapian.sh —— 准备深度拉片素材包:真实语音稿 + 抽帧 + 拉片模板
# 用法: bin/3-lapian.sh <slug> [抽帧间隔秒|auto]
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

SLUG="${1:?用法: bin/3-lapian.sh <slug> [抽帧间隔秒|auto]}"
INTERVAL_ARG="${2:-auto}"
OUT="$ROOT/out.nosync/$SLUG"
LAP="$OUT/lapian"
FRAMES="$LAP/frames"

require_ffmpeg_full
[ -f "$OUT/video.mp4" ] || { echo "❌ 缺少 $OUT/video.mp4,先跑 bin/1-fetch.sh 或把视频放好后跑 bin/transcribe.sh"; exit 1; }
[ -f "$OUT/en.srt" ] || { echo "❌ 缺少 $OUT/en.srt。拉片必须先从真实音频转写,请先跑 bin/transcribe.sh $SLUG"; exit 1; }

mkdir -p "$LAP" "$FRAMES"

echo "[1/4] 真实语音 SRT → 拉片文案包"
python3 "$ROOT/bin/srt-to-md.py" \
  "$OUT/en.srt" \
  "$LAP/speech.en.md" \
  "$LAP/speech.zh.md" \
  "$LAP/speech.segments.tsv" \
  "$LAP/speech.raw.txt"

echo "[2/4] 读取视频信息"
DURATION="$("$FFPROBE" -v error -show_entries format=duration -of default=nw=1:nk=1 "$OUT/video.mp4")"
DIMS="$("$FFPROBE" -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$OUT/video.mp4" 2>/dev/null || true)"
if [ "$INTERVAL_ARG" = "auto" ]; then
  INTERVAL="$(python3 - "$DURATION" <<'PY'
import sys

duration = float(sys.argv[1])
if duration <= 180:
    print(2)
elif duration <= 900:
    print(5)
else:
    print(10)
PY
)"
else
  INTERVAL="$INTERVAL_ARG"
fi
[[ "$INTERVAL" =~ ^[0-9]+$ ]] || { echo "❌ 抽帧间隔必须是整数秒或 auto"; exit 1; }
[ "$INTERVAL" -ge 1 ] || { echo "❌ 抽帧间隔至少 1 秒"; exit 1; }
printf 'slug=%s\nvideo=%s\nduration=%s\nsize=%s\nframe_interval=%s\n' \
  "$SLUG" "$OUT/video.mp4" "$DURATION" "${DIMS:-unknown}" "$INTERVAL" > "$LAP/video.meta.txt"

echo "[3/4] 按 ${INTERVAL}s 抽帧 → $FRAMES"
python3 - "$DURATION" "$INTERVAL" "$FRAMES" > "$LAP/frame-list.tsv" <<'PY'
import math
import sys
from pathlib import Path

duration = float(sys.argv[1])
interval = int(sys.argv[2])
frames = Path(sys.argv[3])

def tc(seconds: int) -> str:
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    return f"{h:02d}-{m:02d}-{s:02d}"

last = max(0, math.floor(duration))
times = list(range(0, last + 1, interval))
if times[-1] != last and last - times[-1] >= max(2, interval // 2):
    times.append(last)
for seconds in times:
    name = f"t_{tc(seconds)}.png"
    print(f"{seconds}\t{name}\t{frames / name}")
PY

while IFS=$'\t' read -r sec name path; do
  [ -n "$sec" ] || continue
  "$FF_FULL" -y -loglevel error -ss "$sec" -i "$OUT/video.mp4" \
    -frames:v 1 -vf "scale='min(960\,iw)':-2" "$path"
done < "$LAP/frame-list.tsv"

echo "[4/4] 写出抽帧索引和拉片模板"
python3 - "$LAP/frame-list.tsv" "$LAP/frames.md" <<'PY'
import sys
from pathlib import Path

frame_list = Path(sys.argv[1])
out = Path(sys.argv[2])
lines = ["# 抽帧索引", "", "这些帧按固定间隔从 `video.mp4` 抽取,用于观察构图、剪辑节奏、屏幕变化和 B-roll。", ""]
for row in frame_list.read_text(encoding="utf-8").splitlines():
    if not row.strip():
        continue
    sec, name, _path = row.split("\t", 2)
    h, rem = divmod(int(float(sec)), 3600)
    m, s = divmod(rem, 60)
    stamp = f"{h:02d}:{m:02d}:{s:02d}"
    lines.extend([f"## {stamp}", "", f"![{stamp}](frames/{name})", ""])
out.write_text("\n".join(lines), encoding="utf-8")
PY

if [ ! -f "$LAP/lapian.md" ]; then
  cat > "$LAP/lapian.md" <<'EOF'
# 深度拉片：填写选题名称

> 填写规则: 必须先读 `speech.en.md` 和 `speech.zh.md`,口播内容以真实音频转写为准。`frames.md` 只用于观察画面和剪辑,不能代替文案。忽略平台下载水印、账号浮层、平台图标等非创作者主动设计的残留信息。

## 一句话定位

## 真实口播文案

见 `speech.zh.md`。如有听写修正,在下方“听写修正”里说明。

## 时间轴拉片

| 时间码 | 阶段/功能 | 中文文案 | 对应画面 | 为什么有效 | 下次怎么拍 |
|---|---|---|---|---|---|
| 00:00-00:00 | 开头｜功能 | 真实口播中文翻译 | 短动作链,如“成品出现 → 手拿卡片入画” | 这段为什么抓人/讲清楚 | 下次拍摄时可以怎么照着做 |

## 可复用拍法总结（好懂版）

| 项目 | 说明 |
|---|---|
| 整条怎么拍 |  |
| 开头怎么做 |  |
| 中段怎么做 |  |
| 信息复杂时怎么办 |  |
| 结尾怎么收 |  |
| 镜头怎么稳 |  |
| 下次怎么用 |  |

## 听写修正

| 原误听/不确定 | 修正 | 说明 |
|---|---|---|
EOF
fi

echo
echo "✅ 拉片素材包完成:"
echo "  $LAP/speech.en.md        真实英文语音稿"
echo "  $LAP/speech.zh.md        中文翻译模板"
echo "  $LAP/frames.md           抽帧索引"
echo "  $LAP/lapian.md           拉片报告模板"
echo
echo "下一步:Codex 逐句翻译 speech.en.md → speech.zh.md,再按“时间码/阶段/中文文案/对应画面/为什么有效/下次怎么拍”填写 lapian.md → bin/lapian-render.sh $SLUG"
