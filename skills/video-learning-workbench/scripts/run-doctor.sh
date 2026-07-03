#!/usr/bin/env bash
# Run repository doctor from a provided repo path or current directory.
set -euo pipefail

REPO="${1:-$PWD}"
if [ ! -x "$REPO/bin/doctor.sh" ]; then
  echo "Missing executable bin/doctor.sh under: $REPO" >&2
  exit 1
fi

"$REPO/bin/doctor.sh"
