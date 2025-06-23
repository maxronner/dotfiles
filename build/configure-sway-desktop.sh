#!/usr/bin/env bash

echo "Overriding sway .desktop file..."
sudo sed -i -E "s|^([[:space:]]*Exec=)(sway)(.*)$$|\1sh -c 'export XDG_CURRENT_DESKTOP=sway \&\& \2\3'|" /usr/share/wayland-sessions/sway.desktop
