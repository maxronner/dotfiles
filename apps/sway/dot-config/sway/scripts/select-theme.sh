#!/usr/bin/env bash

theme="$(
  thememanager list |
    tofi --prompt-text "theme: "
)" || exit 1

[ -n "$theme" ] || exit 1
thememanager set "$theme"
