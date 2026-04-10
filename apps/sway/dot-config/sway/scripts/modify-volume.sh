#!/bin/bash

# Get the current volume
current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
new_volume=$current_volume

if [[ "$1" == "+" ]]; then
    if (( current_volume % 5 != 0 )); then
        new_volume=$(( (current_volume / 5) * 5 ))
    else
        # If already a multiple of 5, increase by 5
        new_volume=$((current_volume + 5))
    fi
    if (( new_volume > 100 )); then
        new_volume=100
    fi
elif [[ "$1" == "-" ]]; then
    if (( current_volume % 5 != 0 )); then
        new_volume=$(( (current_volume / 5) * 5 ))
    else
        new_volume=$((current_volume - 5))
    fi
    if (( new_volume < 0 )); then
        new_volume=0
    fi
fi

if (( new_volume > 100 )); then
    new_volume=100
elif (( new_volume < 0 )); then
    new_volume=0
fi

pactl set-sink-volume @DEFAULT_SINK@ "${new_volume}%"
