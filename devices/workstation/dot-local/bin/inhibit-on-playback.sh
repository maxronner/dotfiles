#!/usr/bin/env bash
set -euo pipefail

# Configuration
LOG_TAG="[inhibit-on-playback]"

log() {
    echo "$LOG_TAG $*" >&2
}

inhibited=false
inhibit() {
    swaymsg 'inhibit_idle open' >/dev/null
    inhibited=true
}

release() {
    swaymsg 'inhibit_idle none' >/dev/null
    inhibited=false
}

set_inhibition() {
    local state=$1 # "on" or "off"
    if [[ "$state" == "on" ]] && [[ "$inhibited" == false ]]; then
        inhibit
        log "Active (Inhibitor created)"
    elif [[ "$state" == "off" ]] && [[ "$inhibited" == true ]]; then
        release
        log "Idle (Inhibitor released)"
    fi
}

cleanup() {
    log "Stopping..."
    release || log 1 "Failed to release inhibitor" && true
    log "Stopped gracefully"
}
trap cleanup EXIT

log "Monitoring playback..."

declare -A active_players=()

playerctl --follow metadata --format '{{playerName}}|{{status}}' 2>/dev/null | while IFS='|' read -r player status; do
    [[ -z "$player" || -z "$status" ]] && continue
    case "$status" in
        Playing)
            active_players["$player"]=1
            ;;
        *)
            unset active_players["$player"]
            ;;
    esac
    if [[ ${#active_players[@]} -gt 0 ]]; then
        set_inhibition "on"
    else
        set_inhibition "off"
    fi
done
