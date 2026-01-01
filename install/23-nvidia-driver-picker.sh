#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

mapfile -t NVIDIA_GPUS < <(lspci -nn | grep -i nvidia | grep -oP '\[10de:\K[0-9a-fA-F]{4}')

if [ ${#NVIDIA_GPUS[@]} -eq 0 ]; then
    warn "No NVIDIA GPU found, skipping driver installation."
    exit 0
fi

DEVICE_ID="${NVIDIA_GPUS[0],,}"

get_generation() {
    case "$1" in
        1e02|1e04|1e07|1e30|1e37|1e81|1e82|1e84|1e87|1f02|1f06|1f07|2182|2184|1f82|1f83)
            echo "turing"
            ;;
        2204|2206|2208|2484|2486|249c|25b6|25b8|25c2|25e2|25e7)
            echo "ampere"
            ;;
        2704|2705|2706|2708|270a|2782|2786|27b6)
            echo "ada"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

GEN=$(get_generation "$DEVICE_ID")

case "$GEN" in
    turing|ampere)
        "${PACKAGE_MANAGER[@]}" "nvidia-open"
        ;;
    ada)
        error "NVIDIA GPU detected (device ID: $DEVICE_ID). No driver installed by default. Manual intervention required."
        exit 1
        ;;
    unknown)
        error "Unknown NVIDIA GPU device ID: $DEVICE_ID. No driver installed."
        exit 1
        ;;
    *)
        error "Older NVIDIA GPU detected (device ID: $DEVICE_ID). No driver installed by default."
        exit 1
        ;;
esac

