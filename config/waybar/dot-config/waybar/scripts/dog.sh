#!/bin/bash
set -euo pipefail

WALK_THRESHOLD=240

walk="0:00"
if [[ -n "${HA_TOKEN:-}" ]]; then
    response=$(curl -sf \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        https://home.ronner.dev/api/states/sensor.walking_dog_digital) || true

    walk=$(jq -r '.state' <<< "$response" 2>/dev/null || echo "0:00")
fi

# Fallback and format guard
if [[ ! "$walk" =~ ^[0-9]+:[0-9]{2}$ ]]; then
    walk="0:00"
fi

IFS=':' read -r hours minutes <<< "$walk"
total_minutes=$((10#$hours * 60 + 10#$minutes))

if (( total_minutes > WALK_THRESHOLD )); then
    echo "{\"text\": \"$walk\", \"tooltip\": \"Time since last walk\", \"class\": \"warning\"}"
else
    echo "{\"text\": \"$walk\", \"tooltip\": \"Time since last walk\", \"class\": \"default\"}"
fi

