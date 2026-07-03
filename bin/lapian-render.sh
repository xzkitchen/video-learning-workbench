#!/usr/bin/env bash
# lapian-render.sh —— 把深度拉片 Markdown 渲染成 HTML,方便浏览器查看/导入飞书
# 用法: bin/lapian-render.sh <slug>
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

SLUG="${1:?用法: bin/lapian-render.sh <slug>}"
OUT="$ROOT/out.nosync/$SLUG/lapian"
SRC="$OUT/lapian.md"
DST="$OUT/lapian.html"

[ -f "$SRC" ] || { echo "❌ 缺少 $SRC,先跑 bin/3-lapian.sh $SLUG 并填写拉片报告"; exit 1; }
python3 -c "import markdown" 2>/dev/null || { echo "❌ 缺 python 库 markdown,先跑 bin/setup.sh"; exit 1; }

python3 - "$SRC" "$DST" "$SLUG" <<'PY'
import re
import sys
from pathlib import Path
import markdown

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
slug = sys.argv[3]
body = markdown.markdown(src.read_text(encoding="utf-8"), extensions=["extra", "sane_lists", "tables"])
m = re.search(r"<h1[^>]*>(.*?)</h1>", body, re.S)
title = re.sub("<[^>]+>", "", m.group(1)).strip() if m else f"{slug} 深度拉片"
html = f"""<!doctype html><html lang="zh-CN"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>
body{{font-family:-apple-system,"PingFang SC","Hiragino Sans GB","Microsoft YaHei",sans-serif;line-height:1.75;color:#171717;background:#f5f5f5;margin:0}}
.wrap{{max-width:980px;margin:0 auto;padding:44px 24px 96px;background:#fff;box-shadow:0 1px 36px rgba(0,0,0,.06)}}
h1{{font-size:2rem;line-height:1.3;margin:.1em 0 .8em}}
h2{{font-size:1.35rem;margin:2em 0 .7em;padding-top:.5em;border-top:1px solid #e8e8e8}}
h3{{font-size:1.08rem;margin:1.4em 0 .45em}}
p,li{{font-size:1rem}}
blockquote{{color:#555;border-left:4px solid #ddd;margin:1.2em 0;padding:.2em 1em;background:#fafafa}}
table{{width:100%;border-collapse:collapse;margin:1em 0 1.4em;font-size:.94rem}}
th,td{{border:1px solid #e6e6e6;padding:8px 10px;vertical-align:top}}
th{{background:#f4f4f4;text-align:left}}
img{{max-width:100%;height:auto;border-radius:6px;display:block;margin:1em auto;box-shadow:0 2px 14px rgba(0,0,0,.08)}}
code{{background:#f0f0f2;padding:.1em .35em;border-radius:4px;font-size:.92em}}
a{{color:#245fd6;text-decoration:none}} a:hover{{text-decoration:underline}}
</style></head><body><div class="wrap">
{body}
</div></body></html>"""
dst.write_text(html, encoding="utf-8")
print(f"✅ 写出 {dst}")
PY

echo "拉片网页:$DST"
