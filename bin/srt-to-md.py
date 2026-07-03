#!/usr/bin/env python3
"""Convert a Whisper SRT into transcript files for deep video breakdowns."""
from __future__ import annotations

import argparse
import re
from pathlib import Path


TIME_RE = re.compile(
    r"(?P<start>\d{2}:\d{2}:\d{2},\d{3})\s+-->\s+"
    r"(?P<end>\d{2}:\d{2}:\d{2},\d{3})"
)


def parse_time(value: str) -> float:
    hms, ms = value.split(",")
    hours, minutes, seconds = [int(part) for part in hms.split(":")]
    return hours * 3600 + minutes * 60 + seconds + int(ms) / 1000


def format_time(seconds: float) -> str:
    seconds = max(0, int(round(seconds)))
    hours, rem = divmod(seconds, 3600)
    minutes, secs = divmod(rem, 60)
    if hours:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    return f"{minutes:02d}:{secs:02d}"


def escape_table(value: str) -> str:
    return value.replace("|", r"\|").replace("\n", "<br>")


def parse_srt(path: Path) -> list[dict[str, object]]:
    text = path.read_text(encoding="utf-8-sig", errors="ignore")
    segments: list[dict[str, object]] = []
    for block in re.split(r"\n\s*\n", text.strip()):
        lines = [line.strip() for line in block.splitlines() if line.strip()]
        if len(lines) < 2:
            continue
        time_index = next((i for i, line in enumerate(lines) if TIME_RE.search(line)), -1)
        if time_index == -1:
            continue
        match = TIME_RE.search(lines[time_index])
        if not match:
            continue
        body = " ".join(lines[time_index + 1 :]).strip()
        body = re.sub(r"\s+", " ", body)
        if not body:
            continue
        start = match.group("start")
        end = match.group("end")
        segments.append(
            {
                "start": start,
                "end": end,
                "start_s": parse_time(start),
                "end_s": parse_time(end),
                "text": body,
            }
        )
    return segments


def group_segments(
    segments: list[dict[str, object]],
    max_seconds: float = 12,
    max_chars: int = 260,
) -> list[dict[str, object]]:
    groups: list[dict[str, object]] = []
    current: list[dict[str, object]] = []

    def flush() -> None:
        nonlocal current
        if not current:
            return
        groups.append(
            {
                "start_s": current[0]["start_s"],
                "end_s": current[-1]["end_s"],
                "text": " ".join(str(item["text"]) for item in current),
            }
        )
        current = []

    for segment in segments:
        if not current:
            current = [segment]
            continue
        start_s = float(current[0]["start_s"])
        end_s = float(segment["end_s"])
        text_len = sum(len(str(item["text"])) for item in current) + len(str(segment["text"]))
        if end_s - start_s > max_seconds or text_len > max_chars:
            flush()
        current.append(segment)
    flush()
    return groups


def write_speech_md(path: Path, source: Path, segments: list[dict[str, object]]) -> None:
    groups = group_segments(segments)
    lines: list[str] = [
        "# 真实语音转写",
        "",
        f"来源: `{source}`",
        "",
        "说明: 这份文案来自 `video.mp4` 的真实音频,由 whisper.cpp 转写得到。拉片时以这里为准,不要用平台字幕、标题或简介替代口播内容。",
        "",
        "## 按段合并文案",
        "",
    ]
    for group in groups:
        start = format_time(float(group["start_s"]))
        end = format_time(float(group["end_s"]))
        lines.extend([f"### {start}-{end}", "", str(group["text"]).strip(), ""])

    lines.extend(["## 逐条时间轴", "", "| 时间 | 原文 |", "|---|---|"])
    for segment in segments:
        start = format_time(float(segment["start_s"]))
        end = format_time(float(segment["end_s"]))
        lines.append(f"| {start}-{end} | {escape_table(str(segment['text']))} |")
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def write_zh_template(path: Path, segments: list[dict[str, object]]) -> None:
    groups = group_segments(segments)
    lines: list[str] = [
        "# 真实语音中文翻译",
        "",
        "说明: 逐段翻译 `speech.en.md` 的真实语音文案。时间段必须保留,不要用平台字幕或视频简介补写。",
        "",
        "## 按段翻译",
        "",
    ]
    for group in groups:
        start = format_time(float(group["start_s"]))
        end = format_time(float(group["end_s"]))
        lines.extend([f"### {start}-{end}", "", "（待翻译）", ""])
    path.write_text("\n".join(lines), encoding="utf-8")


def write_tsv(path: Path, segments: list[dict[str, object]]) -> None:
    lines = ["start\tend\ttext"]
    for segment in segments:
        text = str(segment["text"]).replace("\t", " ").replace("\n", " ")
        lines.append(f"{segment['start']}\t{segment['end']}\t{text}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_raw(path: Path, segments: list[dict[str, object]]) -> None:
    path.write_text("\n".join(str(segment["text"]) for segment in segments) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("srt", type=Path)
    parser.add_argument("speech_md", type=Path)
    parser.add_argument("zh_template", type=Path)
    parser.add_argument("segments_tsv", type=Path)
    parser.add_argument("raw_txt", type=Path)
    args = parser.parse_args()

    segments = parse_srt(args.srt)
    if not segments:
        raise SystemExit(f"No SRT segments found in {args.srt}")

    for output in [args.speech_md, args.zh_template, args.segments_tsv, args.raw_txt]:
        output.parent.mkdir(parents=True, exist_ok=True)

    write_speech_md(args.speech_md, args.srt, segments)
    if not args.zh_template.exists():
        write_zh_template(args.zh_template, segments)
    write_tsv(args.segments_tsv, segments)
    write_raw(args.raw_txt, segments)
    print(f"segments={len(segments)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
