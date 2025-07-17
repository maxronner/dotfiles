#!/usr/bin/env bash

echo "Overriding sway .desktop file..."
sudo sed -i -E "s|^(Exec=)sway\$|\1sh -c 'export XDG_CURRENT_DESKTOP=sway \&\& sway'|" /usr/share/wayland-sessions/sway.desktop
