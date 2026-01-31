#!/bin/sh

cursor=$1
normal_size=$2
big_size=$3

STATE_FILE="$XDG_RUNTIME_DIR/sway-giant-cursor"

if [ -f "$STATE_FILE" ]; then
  swaymsg seat seat0 xcursor_theme "$cursor" "$normal_size"
  rm "$STATE_FILE"
else
  swaymsg seat seat0 xcursor_theme "$cursor" "$big_size"
  touch "$STATE_FILE"
fi
