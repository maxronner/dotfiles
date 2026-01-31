#!/bin/bash
pgrep -x waybar >/dev/null && pkill -x waybar || true
export HA_TOKEN=$(pass api/home-assistant)
exec waybar
