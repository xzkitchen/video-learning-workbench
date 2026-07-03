#!/usr/bin/env bash
# web-render.sh —— 把翻译好的 zh.md 渲染成带样式的自包含 HTML(中文排版)
# 用法: bin/web-render.sh <slug>   读 out.nosync/<slug>/zh.md → 写 out.nosync/<slug>/<slug>.zh.html
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

SLUG="${1:?用法: bin/web-render.sh <slug>}"
OUT="$ROOT/out.nosync/$SLUG"
[ -f "$OUT/zh.md" ] || { echo "❌ 缺少 $OUT/zh.md(中文译文),先让 Claude 翻译"; exit 1; }
python3 -c "import markdown" 2>/dev/null || { echo "❌ 缺 python 库 markdown,先跑 bin/setup.sh"; exit 1; }

python3 - "$OUT/zh.md" "$OUT/$SLUG.zh.html" "$SLUG" <<'PY'
import sys, re, markdown
src, dst, slug = sys.argv[1], sys.argv[2], sys.argv[3]
body = markdown.markdown(open(src,encoding='utf-8').read(), extensions=['extra','sane_lists'])
m = re.search(r'<h1[^>]*>(.*?)</h1>', body, re.S)
title = re.sub('<[^>]+>','', m.group(1)).strip() if m else slug
html = f'''<!doctype html><html lang="zh-CN"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>
body{{font-family:-apple-system,"PingFang SC","Hiragino Sans GB","Microsoft YaHei",sans-serif;line-height:1.8;color:#1a1a1a;background:#f7f7f8;margin:0}}
.wrap{{max-width:760px;margin:0 auto;padding:48px 20px 96px;background:#fff;box-shadow:0 1px 40px rgba(0,0,0,.05)}}
h1{{font-size:1.9rem;line-height:1.35;margin:.2em 0 .6em}}
h2{{font-size:1.4rem;margin:2em 0 .6em;padding-top:.5em;border-top:1px solid #eee}}
p,li{{font-size:1.05rem}}
blockquote{{color:#666;border-left:3px solid #ddd;margin:1.2em 0;padding:.2em 1em;background:#fafafa;font-size:.9rem}}
img{{max-width:100%;height:auto;border-radius:10px;display:block;margin:1.4em auto;box-shadow:0 2px 16px rgba(0,0,0,.08)}}
p>em:only-child{{color:#888;font-style:normal;font-size:.9rem;display:block;text-align:center;margin:-0.8em 0 1.8em}}
a{{color:#2a6df5;text-decoration:none}} a:hover{{text-decoration:underline}}
code{{background:#f0f0f2;padding:.1em .35em;border-radius:4px;font-size:.92em}}
ul,ol{{padding-left:1.4em}} li{{margin:.3em 0}}
hr{{border:none;border-top:1px solid #eee;margin:2.4em 0}}
</style></head><body><div class="wrap">
{body}
</div></body></html>'''
open(dst,'w',encoding='utf-8').write(html)
print("✅ 写出", dst, "(%d 字节)"%len(html))
PY
echo "成片网页:$OUT/$SLUG.zh.html(浏览器双击打开)"
