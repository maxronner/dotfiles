#!/usr/bin/env bash

wallpaper_dir="${WALLPAPER_DIR:-$HOME/.local/share/wallpapers}"
wallpaper="$(
  find -L "$wallpaper_dir" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' \
    | tofi --prompt-text "wallpaper: "
)"
[ -n "$wallpaper" ] || exit 1
ln -sf "$wallpaper_dir/$wallpaper" "$HOME/.config/sway/1.wallpaper"
systemctl --user restart swaybg.service
