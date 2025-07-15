#!/usr/bin/env bash

PIDS_TO_KILL=""
if pgrep ghostty >/dev/null; then
  for PID in $(pgrep ghostty); do
    if pstree -p "$PID" | grep -q 'tmux'; then
      PIDS_TO_KILL="$PIDS_TO_KILL $PID"
    fi
  done
fi

if [ -n "$PIDS_TO_KILL" ]; then
  kill $PIDS_TO_KILL
  for PID_KILLED in $PIDS_TO_KILL; do
    while ps -p "$PID_KILLED" > /dev/null; do
      sleep 0.1
    done
    swaymsg exec "ghostty --title=terminal -e zsh -lic tmux-launcher" >/dev/null 2>&1 & disown
  done
fi

