#!/bin/bash

GAMMA_CMD="gammastep -m wayland"

current_mode="off"
PIDS=( $(pidof gammastep) )

if [ ${#PIDS[@]} -gt 0 ]; then
    # Check each pid's cmdline for flags
    for PID in "${PIDS[@]}"; do
        cmdline=$(ps -p $PID -o args=)
        if grep -q -- "-O 3500" <<< "$cmdline"; then
            current_mode="medium"
            break
        elif grep -q -- "-O 2500" <<< "$cmdline"; then
            current_mode="high"
            break
        else
            current_mode="auto"
        fi
    done
fi

shutdown() {
    echo "Stopping gammastep"
    gammastep -x
    pkill -x gammastep
    timeout=5
    while pidof gammastep >/dev/null && (( timeout > 0 )); do
        sleep 1
        ((timeout--))
    done
}

case $current_mode in
    off)
        echo "Starting automatic mode"
        $GAMMA_CMD &
        ;;
    auto)
        echo "Switching to medium intensity (3500K)"
        shutdown
        $GAMMA_CMD -O 3500 &
        ;;
    medium)
        echo "Switching to high intensity (2500K)"
        shutdown
        $GAMMA_CMD -O 2500 -b 0.8 &
        ;;
    high)
        shutdown
        ;;
esac

