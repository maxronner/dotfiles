#!/bin/bash
if [[ -n $HA_TOKEN ]]; then
    walk=$(curl -s \
      -H "Authorization: Bearer $HA_TOKEN" \
      -H "Content-Type: application/json" \
      https://home.ronner.dev/api/states/sensor.walking_dog \ |
    jq '. | .state' | \
    sed 's/"//g')
fi
echo "{\"text\": \"$walk\", \"tooltip\": \"Walking Dog\"}"
