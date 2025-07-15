#!/bin/sh
TITLE="btop-float"
TERMINAL_CMD="ghostty --title=$TITLE -e btop"

# Query Sway tree for matching window
window_info=$(swaymsg -t get_tree | jq --arg title "$TITLE" '
  recurse(.nodes[]?, .floating_nodes[]?)
  | select(.name? == $title)
  | {id, focused, visible, scratchpad_state}')

# No such window found → launch new
if [ -z "$window_info" ]; then
  exec $TERMINAL_CMD &
  exit
fi

# Extract values
id=$(echo "$window_info" | jq -r '.id // empty')
focused=$(echo "$window_info" | jq -r '.focused // false')
scratchpad_state=$(echo "$window_info" | jq -r '.scratchpad_state // "none"')

# Sanity check for id
if [ -z "$id" ]; then
  echo "Error: Found window without con_id." >&2
  exit 1
fi

# Apply logic
if [ "$focused" = "true" ]; then
  swaymsg "[con_id=$id] move scratchpad"
elif [ "$scratchpad_state" != "none" ]; then
  swaymsg "[con_id=$id] scratchpad show"
else
  swaymsg "[con_id=$id] move to workspace current; [con_id=$id] focus"
fi

