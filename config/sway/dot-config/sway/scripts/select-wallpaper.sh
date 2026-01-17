#!/usr/bin/env bash

wallpaper_dir="${WALLPAPER_DIR:-$HOME/.local/share/wallpapers}"
wallpaper="$(
  find -L "$wallpaper_dir" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' \
    | sort -R \
    | tofi --prompt-text "wallpaper: "
)"
[ -n "$wallpaper" ] || exit 1
set-wallpaper "$wallpaper"
systemctl --user restart swaybg.service
