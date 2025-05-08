#!/bin/bash

# Get the current volume
current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')

# If increasing volume, make sure it doesn't exceed 100%
if [[ "$1" == "+" ]]; then
    new_volume=$((current_volume + 5))
    if (( new_volume > 100 )); then
        new_volume=100
    fi
# If decreasing volume, make sure it doesn't go below 0%
elif [[ "$1" == "-" ]]; then
    new_volume=$((current_volume - 5))
    if (( new_volume < 0 )); then
        new_volume=0
    fi
fi

# Set the volume
pactl set-sink-volume @DEFAULT_SINK@ ${new_volume}%

