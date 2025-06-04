#!/bin/bash

if ! command -v sensors &> /dev/null; then
  echo "Error: sensors command not found.  Please install lm-sensors." >&2
  exit 1
fi

if ! sensors | grep -q "Coolant:"; then
  echo "Warning: Coolant not detected by sensors. Please ensure it is properly configured and detected by lm-sensors." >&2
  exit 1
fi

TEMP=$(sensors | awk '/Coolant:/ { gsub(/\+/, "", $2); print $2 }')
echo "{\"text\": \"$TEMP\", \"tooltip\": \"Kraken AIO Temp\"}"
