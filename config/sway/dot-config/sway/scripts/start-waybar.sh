#!/bin/bash
pgrep -x waybar >/dev/null && pkill -x waybar || true
export HA_TOKEN=$(pass Credentials/tokens/home-assistant)
exec waybar

