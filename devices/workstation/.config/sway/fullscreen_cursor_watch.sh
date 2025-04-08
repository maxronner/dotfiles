#!/bin/bash
# Purpose: Subscribes to sway IPC window events and toggles pointer mapping
# so that when a target app is fullscreen, the input device is mapped
# exclusively to a target output. When the app is not fullscreen or is closed,
# the pointer mapping is reset.

# --- Configuration Variables ---
CMDLINE_MATCH="gamescope"          # Change to the app_id or window class of your game
INPUT_DEVICE="9610:39:SINOWEALTH_Wired_Gaming_Mouse"  # The identifier of your mouse device
TARGET_OUTPUT="DP-1"         # The output (monitor) where the game runs
LOG_LEVEL="info"             # Set the default log level (normal, info, debug)

# Allow override from command line arguments
if [[ -n "$1" ]]; then
    CMDLINE_MATCH="$1"
    echo "Using CMDLINE_MATCH: '$CMDLINE_MATCH'"
fi

if [[ -n "$2" ]]; then
    INPUT_DEVICE="$2"
    echo "Using INPUT_DEVICE: '$INPUT_DEVICE'"
fi

if [[ -n "$3" ]]; then
    TARGET_OUTPUT="$3"
    echo "Using TARGET_OUTPUT: '$TARGET_OUTPUT'"
fi

if [[ -n "$4" ]]; then
    LOG_LEVEL="$4"
    echo "Using LOG_LEVEL: '$LOG_LEVEL'"
fi

# Log levels
LOG_NORMAL=1
LOG_INFO=2
LOG_DEBUG=3

# Determine the numeric log level
case "$LOG_LEVEL" in
    normal) LOG_LEVEL_NUM=$LOG_NORMAL ;;
    info) LOG_LEVEL_NUM=$LOG_INFO ;;
    debug) LOG_LEVEL_NUM=$LOG_DEBUG ;;
    *) LOG_LEVEL_NUM=$LOG_INFO ;;
esac

# Track state
CURRENT_PID=""
CURRENT_MAPPED="false"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"

    case "$level" in
        normal) level_num=$LOG_NORMAL ;;
        info) level_num=$LOG_INFO ;;
        debug) level_num=$LOG_DEBUG ;;
        *) level_num=$LOG_INFO ;;
    esac

    if [[ $LOG_LEVEL_NUM -ge $level_num ]]; then
        echo "[$(date '+%F %T')] [$level] $message"
    fi
}

# Get the executable path (command line) from PID
get_cmdline() {
    local pid="$1"
    if [[ -r /proc/$pid/cmdline ]]; then
        tr '\0' ' ' < /proc/$pid/cmdline | awk '{$1=$1};1'
    fi
}

# Main logic: evaluate JSON window event
handle_event() {
    local json="$1"

    # Defensive parse: validate JSON first
    if ! echo "$json" | jq . &>/dev/null; then
        log normal "Skipping invalid JSON: $json"
        return
    fi

    log debug "Raw JSON: $json"

    local has_container=$(echo "$json" | jq -e 'has("container")') || return
    local pid=$(echo "$json" | jq -r '.container.pid // empty')
    local fullscreen=$(echo "$json" | jq -r '.container.fullscreen_mode // 0')
    local app_name=$(echo "$json" | jq -r '.container.window_properties.class // "(unknown)"')
    local app_id=$(echo "$json" | jq -r '.container.app_id // "(null)"')
    local title=$(echo "$json" | jq -r '.container.name // "(no name)"')
    local shell_type=$(echo "$json" | jq -r '.container.shell // "(none)"')
    local change=$(echo "$json" | jq -r '.change // "(no change)"')

    log info "Event: $change"
    log info "App Class: $app_name | App ID: $app_id | Title: $title | PID: $pid | Fullscreen: $fullscreen | Shell: $shell_type"

    if [[ -z "$pid" || "$fullscreen" == "0" ]]; then
        disable_grab
        return
    fi

    local cmdline
    cmdline=$(get_cmdline "$pid")

    if [[ -z "$cmdline" ]]; then
        log normal "No cmdline found for PID $pid, skipping"
        disable_grab
        return
    fi

    log debug "Cmdline: $cmdline"

    if [[ "$cmdline" == *"$CMDLINE_MATCH"* ]]; then
        CURRENT_PID="$pid"
        enable_grab
    else
        disable_grab
    fi
}

enable_grab() {
    if [[ "$CURRENT_MAPPED" == "true" ]]; then
        return
    fi
    if swaymsg input "$INPUT_DEVICE" map_to_output "$TARGET_OUTPUT" > /dev/null; then
        log normal "Pointer grab ENABLED on $TARGET_OUTPUT for device '$INPUT_DEVICE'"
        CURRENT_MAPPED="true"
    else
        log normal "ERROR: Failed to enable pointer grab"
    fi
}

disable_grab() {
    if [[ "$CURRENT_MAPPED" != "true" ]]; then
        return
    fi
    if swaymsg input "$INPUT_DEVICE" map_to_output "*" > /dev/null; then
        log normal "Pointer grab DISABLED (restored to all outputs)"
        CURRENT_MAPPED="false"
    else
        log normal "ERROR: Failed to disable pointer grab"
    fi
}

# Requires jq
if ! command -v jq &>/dev/null; then
    echo "jq is required but not installed."
    exit 1
fi

log info "Starting fullscreen cursor grab monitor..."

# Persistent subscription to survive swaymsg exit
while true; do
    swaymsg -t subscribe '["window"]'
    log normal "Subscription ended; reconnecting..."
done | while read -r line; do
    handle_event "$line"
done
