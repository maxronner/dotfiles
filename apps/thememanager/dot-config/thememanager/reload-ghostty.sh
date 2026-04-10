#!/usr/bin/env bash
set -euo pipefail

mapfile -t pids < <(pgrep -f "ghostty" || true)
count=${#pids[@]}

if [ "$count" -eq 0 ]; then
  exit 0
fi

kill -USR2 "${pids[@]}" || true
exit 0
