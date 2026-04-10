#!/usr/bin/env bash
set -euo pipefail

WALK_THRESHOLD=240

throw() { exit 0; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

response="$("$script_dir/ha-state.sh" "sensor.walking_dog_digital" 2>/dev/null || true)"
[[ -n "$response" ]] || throw

walk="$(jq -r '.state // empty' <<<"$response" 2>/dev/null || true)"
[[ "$walk" =~ ^[0-9]+:[0-9]{2}$ ]] || throw

IFS=':' read -r hours minutes <<<"$walk"
total_minutes=$((10#$hours * 60 + 10#$minutes))
class="default"
if (( total_minutes > WALK_THRESHOLD * 3 / 2 )); then
  class="critical"
elif (( total_minutes > WALK_THRESHOLD )); then
  class="warning"
fi

jq -cn \
  --arg text "$walk" \
  --arg tooltip "Time since last walk" \
  --arg class "$class" \
  'if $class == "" then {text:$text, tooltip:$tooltip} else {text:$text, tooltip:$tooltip, class:$class} end'
