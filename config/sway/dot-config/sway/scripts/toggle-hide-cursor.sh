#!/bin/sh

STATE_FILE="$XDG_RUNTIME_DIR/sway-hide-cursor"

if [ -f "$STATE_FILE" ]; then
    swaymsg 'seat * hide_cursor 1000' >/dev/null
    rm "$STATE_FILE"
else
    swaymsg 'seat * hide_cursor 0' >/dev/null
    touch "$STATE_FILE"
fi

