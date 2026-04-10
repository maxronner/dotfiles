#!/usr/bin/env bash

gtk_conf_file="$HOME/.config/environment.d/gtk.conf"

if [[ ! -f "$gtk_conf_file" ]]; then
  echo "GTK configuration file not found. Exiting."
  exit
fi

gtk_theme=""
while IFS= read -r raw_line; do
  line="${raw_line%%#*}"
  if [[ "$line" =~ ^[[:space:]]*GTK_THEME[[:space:]]*=[[:space:]]*(.+)[[:space:]]*$ ]]; then
    gtk_theme="${BASH_REMATCH[1]}"
  fi
done < "$gtk_conf_file"

if [[ -z "$gtk_theme" ]]; then
  echo "GTK_THEME entry not found in $gtk_conf_file" >&2
  exit 1
fi

export GTK_THEME="$gtk_theme"

systemctl --user import-environment GTK_THEME
systemctl --user restart gpg-agent
