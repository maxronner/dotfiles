#!/usr/bin/env bash

# Check if at least two arguments are provided
if (( $# < 2 )); then
    echo "Usage: $0 <sink_1> <sink_2> [sink_3 ...]"
    exit 1
fi

# Store all arguments in an array
declare -a SINKS=("$@")
NUM_SINKS=${#SINKS[@]}

current_sink=$(pactl get-default-sink 2>/dev/null)
if [[ -z "$current_sink" ]]; then
    echo "Error: Could not get current default sink. Is PulseAudio running?"
    exit 1
fi

next_sink_index=-1

# Find the current sink in the array and determine the next one
for i in "${!SINKS[@]}"; do
    if [[ "${SINKS[$i]}" == "$current_sink" ]]; then
        next_sink_index=$(( (i + 1) % NUM_SINKS ))
        break
    fi
done

target_sink=""
# If the current sink was found in our list, use the next one.
# Otherwise, default to the first sink in the list.
if (( next_sink_index != -1 )); then
    target_sink="${SINKS[$next_sink_index]}"
    echo "Current sink is '$current_sink'. Attempting to switch to '$target_sink'."
else
    target_sink="${SINKS[0]}"
    echo "Warning: Current sink '$current_sink' not found in provided list. Attempting to set to first sink: '$target_sink'."
fi

pactl set-default-sink "$target_sink"
if [[ $? -eq 0 ]]; then
    echo "Successfully set default sink to '$target_sink'."
else
    echo "Error: Failed to set default sink to '$target_sink'. It might be an invalid sink name or PulseAudio issue."
    exit 1
fi

