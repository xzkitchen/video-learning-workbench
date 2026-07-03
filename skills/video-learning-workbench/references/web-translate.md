# Web Article Translation Workflow

## Steps

1. Fetch the article:

```bash
bin/web-fetch.sh "<article-url>" <slug>
```

2. Translate `out.nosync/<slug>/en.md` to `out.nosync/<slug>/zh.md`.

Rules:

- Read `glossary.md` first.
- Preserve Markdown structure.
- Preserve useful image links.
- Skip navigation, cookie banners, unrelated footers, and repeated page chrome.
- Add a source line at the top when helpful.

3. Render:

```bash
bin/web-render.sh <slug>
```

4. Verify title, section structure, images, and terminology.

## Output

Return:

- `out.nosync/<slug>/zh.md`
- `out.nosync/<slug>/<slug>.zh.html`
