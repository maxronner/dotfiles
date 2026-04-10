#!/bin/bash

mode="$1"
notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -t 2000 "Screenshot $mode" "Copied to clipboard"
  fi
}
case "$mode" in
full)
  grim -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" - | wl-copy && notify
  ;;
focused)
  swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | if (.focused) then select(.focused) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" else (.floating_nodes? // empty)[] | select(.visible) | select(.focused) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" end' | grim -g - - | wl-copy && notify
  ;;
selection)
  geometry=$(slurp -w 0)
  if [ -n "$geometry" ]; then
    grim -g "$geometry" - | wl-copy && notify
  fi
  ;;
*)
  echo "Usage: $(basename "$0") [full|focused|selection]"
  exit 1
  ;;
esac
