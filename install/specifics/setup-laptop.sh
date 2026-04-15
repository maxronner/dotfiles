#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

LAPTOP_DIR="${DOTS_DIR}/devices/laptop"

info "Allow uinput access for kmonad"
sudo tee /etc/udev/rules.d/90-uinput.rules <<'EOF'
KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
EOF

info "Adding user to input group"
sudo usermod -aG input "$USER"

sudo udevadm control --reload-rules
sudo udevadm trigger

info "Installing kmonad system config"
sudo install -Dm644 "${LAPTOP_DIR}/etc/kmonad/qwerty-homerowmods.kbd" /etc/kmonad/qwerty-homerowmods.kbd
sudo install -Dm644 "${LAPTOP_DIR}/etc/systemd/system/kmonad@.service" /etc/systemd/system/kmonad@.service
sudo systemctl daemon-reload
sudo systemctl enable --now kmonad@qwerty-homerowmods.service
