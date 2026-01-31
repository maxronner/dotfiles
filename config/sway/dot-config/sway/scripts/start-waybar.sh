#!/bin/bash
pgrep -x waybar >/dev/null && pkill -x waybar || true
exec waybar
