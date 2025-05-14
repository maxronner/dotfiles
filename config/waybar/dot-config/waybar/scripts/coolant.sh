#!/bin/bash

# Check if sensors command is available
if ! command -v sensors &> /dev/null; then
  echo "Error: sensors command not found.  Please install lm-sensors." >&2
  exit 1
fi

# Check if the Kraken AIO is detected
if ! sensors | grep -q "Coolant:"; then
  echo "Error: Kraken AIO not detected by sensors.  Please ensure it is properly configured and detected by lm-sensors." >&2
  exit 1
fi

TEMP=$(sensors | awk '/Coolant:/ { gsub(/\+/, "", $2); print $2 }')
echo "{\"text\": \"$TEMP\", \"tooltip\": \"Kraken AIO Temp\"}"
