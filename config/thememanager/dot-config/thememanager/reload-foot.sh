#!/usr/bin/env bash

pkill foot || true
swaymsg exec "foot --title=terminal -e zsh -lic tmux-launcher" >/dev/null 2>&1 & disown
