#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

LAPTOP_PKGS=(
  dhcpcd
  kmonad
  iwd
  bluez
  bluez-utils
  sway
)

info "Installing laptop specific packages..."
"${AUR_HELPER[@]}" "${LAPTOP_PKGS[@]}"

info "Setting up dhcpcd..."
sudo systemctl enable --now dhcpcd.service

info "Allow uinput access for kmonad"
sudo tee /etc/udev/rules.d/90-uinput.rules <<'EOF'
KERNEL=="uinput", GROUP="input", MODE="0660"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

