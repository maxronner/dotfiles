#!/usr/bin/env bash
set -euo pipefail

mapfile -t pids < <(pgrep -x "ghostty" || true)
count=${#pids[@]}

if [ "$count" -eq 0 ]; then
  exit 0
fi

kill -USR2 "${pids[@]}" || true
