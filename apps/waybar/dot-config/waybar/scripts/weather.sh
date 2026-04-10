#!/usr/bin/env bash
set -euo pipefail

basename="${0##*/}"
basename="${basename%.sh}"

fallback() {
  jq -cn --arg text "N/A" --arg tooltip "$basename unavailable" \
    '{text:$text, tooltip:$tooltip}'
}

throw() { fallback; exit 0; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
response="$("$script_dir/ha-state.sh" "weather.forecast_home" 2>/dev/null || true)"
[[ -n "$response" ]] || throw

jq -c '{text: "\(.attributes.temperature)\(.attributes.temperature_unit)", tooltip: .state, alt: .state}' \
  <<<"$response" 2>/dev/null || throw
