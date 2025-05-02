#!/bin/bash
TEMP=$(sensors | awk '/Coolant:/ { gsub(/\+/, "", $2); print $2 }')
echo "{\"text\": \"$TEMP\", \"tooltip\": \"Kraken AIO Temp\"}"
