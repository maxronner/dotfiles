#!/usr/bin/env bash

wallpaper_dir="${WALLPAPER_DIR:-$HOME/.local/share/wallpapers}"
wallpaper="$(
  find -L "$wallpaper_dir" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' \
    | tofi --prompt-text wallpaper:
)"
[ -n "$wallpaper" ] || exit 1
systemctl --user set-environment WALLPAPER_IMAGE="$wallpaper_dir/$wallpaper"
systemctl --user restart sway-wallpaper.service
systemctl --user unset-environment WALLPAPER_IMAGE

