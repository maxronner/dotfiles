#!/bin/bash
set -euo pipefail

# Validate dependencies
type -P sensors &>/dev/null || {
  echo 'Error: sensors command not found. Please install lm-sensors.' >&2
  exit 1
}

# Cache sensors output to avoid multiple subprocess calls
sensors_data=$(sensors 2>/dev/null) || {
  echo 'Error: Failed to read sensors data' >&2
  exit 1
}

# Parse coolant temperature using bash builtins [Bash]
[[ "$sensors_data" == *"Coolant:"* ]] || {
  echo 'Warning: Coolant not detected by sensors. Please ensure it is properly configured and detected by lm-sensors.' >&2
  exit 1
}

# Extract temperature value [POSIX pattern matching via Bash]
while IFS= read -r line; do
  if [[ "$line" == *"Coolant:"* ]]; then
    # Extract temp value (e.g., "+32.5°C" -> "32.5°C")
    temp=${line#*Coolant:}
    temp=${temp#*+}
    temp=${temp%%°*}
    printf '{"text": "%s", "tooltip": "Kraken AIO Temp"}\n' "$temp°C"
    exit 0
  fi
done <<< "$sensors_data"

exit 1
