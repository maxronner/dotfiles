#!/usr/bin/env bash

theme="$(
  "$HOME/.local/bin/thememanager" list |
    tofi --prompt-text "theme: "
)" || exit 1

[ -n "$theme" ] || exit 1
"$HOME/.local/bin/thememanager" set "$theme"
