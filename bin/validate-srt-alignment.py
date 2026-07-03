#!/usr/bin/env python3
# validate-srt-alignment.py —— 检查译文 SRT 是否保留原字幕编号和时间轴
# 用法: python3 bin/validate-srt-alignment.py <en.srt> <zh.srt>
import re
import sys
from pathlib import Path

TIME_RE = re.compile(
    r"^\d{2}:\d{2}:\d{2},\d{3}\s+-->\s+\d{2}:\d{2}:\d{2},\d{3}"
)


def parse(path):
    text = Path(path).read_text(encoding="utf-8-sig").strip()
    if not text:
        return []
    cues = []
    for raw in re.split(r"\n\s*\n", text):
        lines = [line.strip() for line in raw.splitlines() if line.strip()]
        if not lines:
            continue
        time_i = next((i for i, line in enumerate(lines) if "-->" in line), None)
        if time_i is None:
            cues.append({"id": lines[0], "time": "", "text": ""})
            continue
        cue_id = lines[time_i - 1] if time_i > 0 else ""
        time_line = lines[time_i]
        body = "\n".join(lines[time_i + 1 :]).strip()
        cues.append({"id": cue_id, "time": time_line, "text": body})
    return cues


def fail(msg):
    print(f"❌ {msg}", file=sys.stderr)
    sys.exit(1)


def main():
    if len(sys.argv) != 3:
        fail("用法: validate-srt-alignment.py <en.srt> <zh.srt>")

    src = parse(sys.argv[1])
    dst = parse(sys.argv[2])
    if len(src) != len(dst):
        fail(f"字幕条数不一致: 原文 {len(src)} 条, 译文 {len(dst)} 条。不要增删、合并或重排字幕块。")

    problems = []
    empty_text = []
    for i, (a, b) in enumerate(zip(src, dst), 1):
        if a["id"] != b["id"]:
            problems.append(f"第 {i} 条编号不同: {a['id']!r} != {b['id']!r}")
        if a["time"] != b["time"]:
            problems.append(f"第 {i} 条时间码不同: {a['time']!r} != {b['time']!r}")
        if not TIME_RE.match(b["time"]):
            problems.append(f"第 {i} 条译文时间码格式异常: {b['time']!r}")
        if not b["text"]:
            empty_text.append(str(i))

    if empty_text:
        problems.append("译文内容为空: 第 " + ", ".join(empty_text[:20]) + " 条")

    if problems:
        print("❌ zh.srt 没有保留 en.srt 的编号和时间轴。请先修正再烧字幕。", file=sys.stderr)
        for item in problems[:20]:
            print(f"- {item}", file=sys.stderr)
        if len(problems) > 20:
            print(f"- 其余 {len(problems) - 20} 个问题省略", file=sys.stderr)
        sys.exit(1)

    print(f"✅ SRT 对齐检查通过: {len(src)} 条字幕编号和时间码一致")


if __name__ == "__main__":
    main()
