#!/usr/bin/env bash
# web-fetch.sh —— 抓网页正文转成 markdown + 提取图片 URL(供 Claude 翻译)
# 用法: bin/web-fetch.sh "<网页URL>" <slug>
#   产出 out.nosync/<slug>/{page.html, en.md, images.txt};之后 Claude 译成 zh.md → bin/web-render.sh
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

URL="${1:?用法: bin/web-fetch.sh \"<网页URL>\" <slug>}"
SLUG="${2:?用法: bin/web-fetch.sh \"<网页URL>\" <slug>}"
OUT="$ROOT/out.nosync/$SLUG"; mkdir -p "$OUT"
python3 -c "import html2text" 2>/dev/null || { echo "❌ 缺 python 库 html2text,先跑 bin/setup.sh"; exit 1; }

echo "[1/2] 抓取 → $OUT/page.html"
curl -sL -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/537.36" "$URL" -o "$OUT/page.html"

echo "[2/2] 转 markdown → $OUT/en.md(+ 提取图片 URL)"
python3 - "$OUT/page.html" "$OUT/en.md" <<'PY'
import sys, html2text
h=open(sys.argv[1],encoding='utf-8',errors='ignore').read()
t=html2text.HTML2Text(); t.body_width=0; t.ignore_links=False; t.ignore_images=False
open(sys.argv[2],'w',encoding='utf-8').write(t.handle(h))
PY
grep -oE 'https://[^")]+\.(png|jpg|jpeg|gif|webp)' "$OUT/page.html" | sort -u > "$OUT/images.txt" || true

echo "✅ 完成:en.md + images.txt($(wc -l < "$OUT/images.txt" | tr -d ' ') 张图)"
echo "下一步:Claude 读 en.md 译成 $OUT/zh.md → bin/web-render.sh $SLUG"
