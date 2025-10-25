#!/usr/bin/env bash
set -euo pipefail
active_inhibit=false

echo "Starting playback monitor..."

playerctl --follow status 2>/dev/null | while read -r status; do
    echo "Status change: $status"
    case "$status" in
        Playing)
            if ! $active_inhibit; then
                echo "Activating idle inhibitor"
                swaymsg 'inhibit_idle open'
                active_inhibit=true
            fi
            ;;
        Paused|Stopped)
            if $active_inhibit; then
                echo "Deactivating idle inhibitor"
                swaymsg 'inhibit_idle none'
                active_inhibit=false
            fi
            ;;
    esac
done

