#!/usr/bin/env bash
# resume-device.sh —— 换设备 / 新 session 接管前的本机状态检查
# 用法: bin/resume-device.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "== 视频学习工作台接管检查 =="
echo "项目目录: $ROOT"
echo

echo "== 1/3 初始化本机轻量目录 =="
"$ROOT/bin/init-project.sh"
echo

echo "== 2/3 检查本机运行环境 =="
if "$ROOT/bin/doctor.sh"; then
  echo
  echo "== 3/3 接管结论 =="
  echo "✅ 当前设备可以继续处理视频 / 网页 / 拉片任务。"
  echo
  echo "说明:"
  echo "  - 脚本和规则通过 iCloud 同步。"
  echo "  - models.nosync 和 out.nosync 是每台设备本地目录,不会自动同步大文件。"
  echo "  - 不要在两台设备上同时处理同一个 slug,避免输出冲突。"
  exit 0
fi

echo
echo "== 3/3 接管结论 =="
echo "❌ 当前设备还缺少运行环境或本地模型。"
echo
echo "请在本项目目录执行:"
echo "  bin/setup.sh"
echo
echo "setup 完成后重新执行:"
echo "  bin/resume-device.sh"
exit 1
