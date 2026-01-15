#!/usr/bin/env bash

# This script is used to change the theme of the system.
# It is called by the tofi command-line tool.

theme_dir="$HOME/.local/share/themes"

theme="$(
  find "$theme_dir" -mindepth 1 -maxdepth 1 -print0 \
    | xargs -0 -n1 basename \
    | tofi --prompt-text theme:
)" || exit 1

[ -n "$theme" ] || exit 1
thememanager set "$theme"

