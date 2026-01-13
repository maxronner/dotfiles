#!/usr/bin/env bash

# Netflix: Still watching?
# Me: Yes, I'm still watching.

if [[ -z "${1:-}" ]]; then
  echo "Error: Home Assistant token not provided as the first argument." >&2
  exit 1
fi

HA_TOKEN="$1"

for i in {1..2}; do
  echo "Attempt $i of 2..."
  response=$(curl -sf \
    -H "Authorization: Bearer $HA_TOKEN" \
    -H "Content-Type: application/json" \
    https://home.ronner.dev/api/services/media_player/media_play_pause \
    -d '{"entity_id": "media_player.hemmabiosystem"}')

  if [[ "$response" == *"error"* ]]; then
    echo "Error: Failed to send command to Home Assistant." >&2
    exit 1
  fi
done
