#!/usr/bin/env bash
set -euo pipefail

GAMMASTEP=(gammastep -m wayland)

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/gammastep-mode"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/gammastep-toggle.lock"

mkdir -p "$(dirname "$STATE_FILE")"

get_mode() { [[ -f "$STATE_FILE" ]] && cat "$STATE_FILE" || echo off; }
set_mode() { printf '%s\n' "$1" >"$STATE_FILE"; }

stop_gammastep() {
  pkill -x -TERM gammastep 2>/dev/null || true
  for _ in {1..25}; do
    pgrep -x gammastep >/dev/null || return 0
    sleep 0.02
  done
  pkill -x -KILL gammastep 2>/dev/null || true
  for _ in {1..10}; do
    pgrep -x gammastep >/dev/null || return 0
    sleep 0.02
  done
}

start_gammastep() {
  "${GAMMASTEP[@]}" "$@" >/dev/null 2>&1 &
  disown || true
}

# --- one-shot lock (never block) ---
exec 9>"$LOCK_FILE"
flock -n -x 9 || exit 0

mode="$(get_mode)"
case "$mode" in
  off)    next=auto ;;
  auto)   next=medium ;;
  medium) next=high ;;
  high)   next=off ;;
  *)      next=off ;;
esac
set_mode "$next"

# release lock early: state is committed, avoid wedging future runs
flock -u 9

case "$next" in
  auto)
    start_gammastep
    ;;
  medium)
    stop_gammastep
    start_gammastep -t 3500:3500
    ;;
  high)
    stop_gammastep
    start_gammastep -t 2500:2500 -b 0.8:0.8
    ;;
  off)
    stop_gammastep
    gammastep -x || true
    ;;
esac

