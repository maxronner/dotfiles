#!/usr/bin/env bash

echo "Disabling USB wakeup for microphone..."
echo "disabled" | sudo tee /sys/bus/usb/devices/5-2/power/wakeup
