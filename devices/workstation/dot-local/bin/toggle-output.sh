#!/usr/bin/env bash

SINK_A=alsa_output.pci-0000_0a_00.4.analog-stereo
SINK_B=alsa_output.pci-0000_08_00.1.hdmi-stereo

current=$(pactl get-default-sink)

if [[ "$current" == "$SINK_A" ]]; then
    pactl set-default-sink "$SINK_B"
else
    pactl set-default-sink "$SINK_A"
fi

