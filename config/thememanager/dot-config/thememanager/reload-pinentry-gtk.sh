#!/usr/bin/env bash

gtk_conf_file="$HOME/.config/environment.d/gtk.conf"

if [[ ! -f "$gtk_conf_file" ]]; then
  echo "GTK configuration file not found. Exiting."
  exit
fi

set -a
source "$gtk_conf_file"
set +a

systemctl --user import-environment GTK_THEME
systemctl --user restart gpg-agent

