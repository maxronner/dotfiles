#!/usr/bin/env bash
set -e

if pgrep -x waybar >/dev/null; then
	pkill -x waybar
else
	exec waybar
fi
