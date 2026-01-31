#!/usr/bin/env bash
set -euo pipefail

CITY=${CITY:-"mmx"}
base_url="https://wttr.in"

if [[ -n "$CITY" ]]; then
  base_url="${base_url}/${CITY}"
fi

curl_opts=(
  -fsSL
  --max-time 8
  --retry 2
  --retry-delay 1
  --user-agent "curl"
)

weather=$(curl "${curl_opts[@]}" "${base_url}?format=1" 2>/dev/null \
  | sed -E 's/^([^[:space:]]+)[[:space:]]+/\1 /' || true)
tooltip=$(curl "${curl_opts[@]}" "${base_url}?0" 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' || true)

if [[ -z "$weather" ]]; then
  weather="N/A"
  tooltip="Weather unavailable"
fi

jq -cn --arg text "$weather" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
