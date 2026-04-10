#!/usr/bin/env bash

set -euo pipefail

mapfile -t pids < <(pgrep -f "ghostty.*tmux-launcher" || true)
count=${#pids[@]}

if [ "$count" -eq 0 ]; then
    exit 0
fi

kill "${pids[@]}" || true

for _ in $(seq 1 30); do
    if ! pgrep -f "ghostty.*tmux-launcher" >/dev/null; then
        break
    fi
    sleep 0.1
done

for _ in $(seq 1 "$count"); do
    swaymsg exec "ghostty --title=terminal -e zsh -lic tmux-launcher" >/dev/null 2>&1
done
