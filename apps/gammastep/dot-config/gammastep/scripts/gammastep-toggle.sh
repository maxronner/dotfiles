#!/usr/bin/env bash
set -euo pipefail

# Cycle gammastep through off/auto/medium/high.
# Lifecycle delegated to the packaged systemd user unit; per-mode args
# applied via a runtime drop-in (tmpfs, auto-clean on logout).
#
# Usage:
#   gammastep-toggle.sh            cycle to next mode
#   gammastep-toggle.sh toggle     same as above
#   gammastep-toggle.sh apply      re-apply the persisted mode (for autostart)

UNIT=gammastep.service
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/gammastep-mode"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
DROPIN_DIR="$RUNTIME_DIR/systemd/user/${UNIT}.d"
DROPIN="$DROPIN_DIR/mode.conf"
LOCK_FILE="$RUNTIME_DIR/gammastep-toggle.lock"

mkdir -p "$(dirname "$STATE_FILE")"

get_mode() { [[ -f "$STATE_FILE" ]] && cat "$STATE_FILE" || echo auto; }
set_mode() { printf '%s\n' "$1" >"$STATE_FILE"; }

write_dropin() {
  mkdir -p "$DROPIN_DIR"
  {
    printf '[Service]\n'
    printf 'ExecStart=\n'
    printf 'ExecStart=/usr/bin/gammastep -m wayland'
    for arg in "$@"; do printf ' %s' "$arg"; done
    printf '\n'
  } >"$DROPIN"
  systemctl --user daemon-reload
}

clear_dropin() {
  rm -f "$DROPIN"
  rmdir "$DROPIN_DIR" 2>/dev/null || true
  systemctl --user daemon-reload 2>/dev/null || true
}

apply_mode() {
  case "$1" in
    auto)   write_dropin ;;
    medium) write_dropin -t 3500:3500 ;;
    high)   write_dropin -t 2500:2500 -b 0.8:0.8 ;;
    off)
      systemctl --user stop "$UNIT" 2>/dev/null || true
      clear_dropin
      gammastep -x >/dev/null 2>&1 || true
      return
      ;;
    *) echo "unknown mode: $1" >&2; exit 1 ;;
  esac
  systemctl --user restart "$UNIT"
}

cmd="${1:-toggle}"
case "$cmd" in
  toggle)
    exec 9>"$LOCK_FILE"
    flock -n -x 9 || exit 0
    case "$(get_mode)" in
      off)    next=auto ;;
      auto)   next=medium ;;
      medium) next=high ;;
      high)   next=off ;;
      *)      next=auto ;;
    esac
    set_mode "$next"
    flock -u 9
    apply_mode "$next"
    ;;
  apply)
    apply_mode "$(get_mode)"
    ;;
  *)
    echo "usage: $0 [toggle|apply]" >&2
    exit 2
    ;;
esac
