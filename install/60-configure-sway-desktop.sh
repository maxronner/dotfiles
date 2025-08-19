#!/usr/bin/env bash

SWAY_DESKTOP_FILE="/usr/share/wayland-sessions/sway.desktop"

echo "Overriding sway .desktop file..."
sudo sed -i -E "s|^(Exec=)sway\$|\1sh -c 'export XDG_CURRENT_DESKTOP=sway \&\& sway'|" $SWAY_DESKTOP_FILE

if lspci -nn | grep -i nvidia; then
    echo "NVIDIA GPU detected, setting --unsupported-gpu flag..."
    sudo sed -i '/^[[:space:]]*Exec=.*sway/ {
  /--unsupported-gpu/! s|\(sway\)\([[:space:]]*['"'"'"]\)|\1 --unsupported-gpu\2|
}' "$SWAY_DESKTOP_FILE"
fi
