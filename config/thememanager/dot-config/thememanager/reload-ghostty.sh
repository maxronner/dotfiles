#!/usr/bin/env bash

pkill ghostty
while pgrep ghostty >/dev/null; do sleep 0.1; done

swaymsg exec "ghostty -e zsh -lic tmux-launcher" >/dev/null 2>&1 & disown
