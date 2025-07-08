#!/bin/sh
# Toggle a btop Ghostty scratchpad window in Sway.

TITLE="btop-float"
TERMINAL_CMD="ghostty --title=$TITLE -e btop"

is_focused() {
    swaymsg -t get_tree | jq -e --arg title "$TITLE" \
        '.. | select(.focused? == true and .name? == $title)' > /dev/null
}

window_exists() {
    swaymsg -t get_tree | jq -e --arg title "$TITLE" \
        '.. | select(.name? == $title)' > /dev/null
}

if is_focused; then
    swaymsg "[title=\"$TITLE\"] move scratchpad"
elif window_exists; then
    swaymsg "[title=\"$TITLE\"] scratchpad show"
else
    eval "$TERMINAL_CMD" &
fi
