#!/bin/bash

# Helper: map device ID to generation
get_generation() {
    case "$1" in
        # Turing (NV160)
        1e02|1e04|1e07|1e30|1e37|1e81|1e82|1e84|1e87|1f02|1f06|1f07|2182|2184|1f82|1f83)
            echo "turing"
            ;;
        # Ampere (NV170)
        2204|2206|2208|2484|2486|249c|25b6|25b8|25c2|25e2|25e7)
            echo "ampere"
            ;;
        # Ada Lovelace (NV190)
        2704|2705|2706|2708|270a|2782|2786|27b6)
            echo "ada"
            ;;
        # Pascal (NV130), Maxwell (NV110), etc.
        *)
            echo "older"
            ;;
    esac
}

# Detect NVIDIA GPU
GPU=$(lspci -nn | grep -i 'VGA' | grep -i 'NVIDIA')
[[ -z "$GPU" ]] && { echo "No NVIDIA GPU found"; exit 1; }

# Extract PCI device ID
DEVICE_ID=$(echo "$GPU" | grep -oP '\[10de:\K[0-9a-f]{4}' | head -n1)

# Determine generation
GEN=$(get_generation "$DEVICE_ID")

# Decide driver
if [[ "$GEN" == "turing" || "$GEN" == "ampere" || "$GEN" == "ada" ]]; then
    echo "nvidia-open"
else
    echo "nvidia"
fi

