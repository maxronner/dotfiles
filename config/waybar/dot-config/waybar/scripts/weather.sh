#!/usr/bin/env bash
set -euo pipefail

fallback='{"text":"N/A","tooltip":"Weather unavailable"}'

if [[ -z "${HA_TOKEN:-}" ]]; then
  echo "$fallback"
  exit 0
fi

response="$(curl -sf \
  -H "Authorization: Bearer $HA_TOKEN" \
  -H "Content-Type: application/json" \
  https://home.ronner.dev/api/states/weather.forecast_home \
  2>/dev/null || true)"

if [[ -z "${response}" ]]; then
  echo "$fallback"
  exit 0
fi

jq -c '{text: "\(.attributes.temperature)\(.attributes.temperature_unit)", tooltip: .state, alt: .state}' \
  <<<"$response" || echo "$fallback"
