#!/usr/bin/env bash

DIR="$XDG_CONFIG_HOME/shell/shell-functions"
for file in "$DIR"/*.sh; do
  [ -r "$file" ] || continue
  # shellcheck source=/dev/null
  source "$file"
done
