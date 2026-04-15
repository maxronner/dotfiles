#!/bin/sh

if pgrep -f pulsemixer-float >/dev/null; then
  pkill -f pulsemixer-float
else
  ghostty --title=pulsemixer-float -e zsh -ic pulsemixer
fi
