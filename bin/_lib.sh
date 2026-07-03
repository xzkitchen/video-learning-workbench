#!/usr/bin/env bash
# _lib.sh —— 视频翻译流水线共享库(被 1-fetch.sh / transcribe.sh / 2-burn.sh source)
# 集中:项目路径、模型、ffmpeg 定位、whisper 提示词、转写核心。改一处即可。
# (clean.sh 也 source 本文件以拿到 ROOT)

# 项目根目录(按本文件自身位置算,与调用方 cwd 无关)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL="$ROOT/models.nosync/ggml-large-v3-turbo.bin"

# ffmpeg-full(含 libass,烧字幕必需)。brew --prefix 动态定位,跨机/Intel 都适用。
BREW_BIN="$(command -v brew || true)"
if [ -z "$BREW_BIN" ]; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      BREW_BIN="$candidate"
      break
    fi
  done
fi
FF_PREFIX=""
if [ -n "$BREW_BIN" ]; then
  FF_PREFIX="$("$BREW_BIN" --prefix ffmpeg-full 2>/dev/null || true)"
fi
FF_FULL="${FF_PREFIX:+$FF_PREFIX/bin/ffmpeg}"
[ -x "$FF_FULL" ] || FF_FULL=""
# 与 ffmpeg-full 同目录的 ffprobe(探测视频朝向用)
FFPROBE="${FF_FULL:+${FF_FULL%/ffmpeg}/ffprobe}"

# 抽音频用任意 ffmpeg 即可(不需要 libass):优先 ffmpeg-full,退而用 PATH 里的 ffmpeg
ff_any() { if [ -n "$FF_FULL" ]; then printf '%s' "$FF_FULL"; else command -v ffmpeg || true; fi; }

require_ffmpeg_full() {
  [ -n "$FF_FULL" ] || { echo "❌ 找不到 ffmpeg-full(烧字幕需要 libass)。先跑 bin/setup.sh"; exit 1; }
}
require_model() {
  [ -f "$MODEL" ] || { echo "❌ 模型不存在:$MODEL。先跑 bin/setup.sh(会自动下载)"; exit 1; }
}

# whisper 提示词:默认适配通用视频口播,同时保留 AI / Claude Code 高频术语。
# 如遇特定题材,可临时加环境变量 WHISPER_PROMPT_EXTRA 补充菜名、人名、品牌名等专有词。
DEFAULT_WHISPER_PROMPT="Clear speech transcription for online videos. Preserve proper nouns, dish names, creator names, product names, place names, and tool names. Do not translate during transcription."
AI_WHISPER_PROMPT="AI and coding terms: LLM, prompt, prompt engineering, system prompt, context, context window, token, agent, agentic, agentic loop, loop, harness, subagent, workflow, MCP, Model Context Protocol, tool use, RAG, retrieval-augmented generation, few-shot, fine-tuning, chain-of-thought, reasoning, hallucination, temperature, verify, iterate, Claude, Claude Code, Anthropic, OpenAI, Cursor, API."
WHISPER_PROMPT="${WHISPER_PROMPT:-$DEFAULT_WHISPER_PROMPT $AI_WHISPER_PROMPT}"
if [ -n "${WHISPER_PROMPT_EXTRA:-}" ]; then
  WHISPER_PROMPT="$WHISPER_PROMPT $WHISPER_PROMPT_EXTRA"
fi

# 转写核心:对 <OUT>/video.mp4 抽 16k 音频 + whisper.cpp 转写 → <OUT>/en.srt
# 用法: transcribe_to_srt <OUT目录> [语言]   语言默认 en,可传 auto / hi / ja 等
transcribe_to_srt() {
  local out="$1" lang="${2:-en}"
  local ff; ff="$(ff_any)"
  [ -x "$ff" ] || { echo "❌ 没找到 ffmpeg。先跑 bin/setup.sh"; exit 1; }
  require_model
  echo "抽取 16kHz 单声道音频..."
  "$ff" -y -loglevel error -i "$out/video.mp4" -ar 16000 -ac 1 -c:a pcm_s16le "$out/audio.wav"
  echo "whisper.cpp 转写字幕(语言=$lang,Metal 加速)..."
  whisper-cli -m "$MODEL" -f "$out/audio.wav" \
    -l "$lang" --prompt "$WHISPER_PROMPT" --carry-initial-prompt \
    -t 8 -pp -osrt -of "$out/en"
  rm -f "$out/audio.wav"   # 转写完即删,纯中间产物,省磁盘
}
