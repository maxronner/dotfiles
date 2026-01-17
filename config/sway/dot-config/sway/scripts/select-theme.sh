#!/usr/bin/env bash

theme_dir="$HOME/.local/share/themes"
theme="$(
  find "$theme_dir" -mindepth 1 -maxdepth 1 -print0 \
    | sort -z \
    | xargs -0 -n1 basename \
    | tofi --prompt-text "theme: "
)" || exit 1

[ -n "$theme" ] || exit 1
thememanager set "$theme"

