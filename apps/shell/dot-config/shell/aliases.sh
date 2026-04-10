#!/usr/bin/env sh

dir=${XDG_CONFIG_HOME:-$HOME/.config}
for f in "$dir/shell/aliases"/*.sh; do
  . "$f"
done
