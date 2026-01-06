#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

LAPTOP_PKGS=(
  bluez
  bluez-utils
  kmonad
  networkmanager
  sway
)

info "Installing laptop specific packages..."
"${AUR_HELPER[@]}" "${LAPTOP_PKGS[@]}"

info "Setting up networking"
sudo systemctl enable --now NetworkManager.service

info "Allow uinput access for kmonad"
sudo tee /etc/udev/rules.d/90-uinput.rules <<'EOF'
KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

