#!/usr/bin/env bash

state=$(swaymsg -t get_inputs \
  | jq -r ".[] | select(.type==\"touchpad\") | .libinput.send_events")

if [ "$state" = "enabled" ]; then
  swaymsg input type:touchpad events disabled
else
  swaymsg input type:touchpad events enabled
fi
