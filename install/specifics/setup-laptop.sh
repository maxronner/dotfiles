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

echo "Installing laptop specific packages..."
"${AUR_HELPER[@]}" "${LAPTOP_PKGS[@]}"

echo "Setting up dhcpcd..."
sudo systemctl enable --now dhcpcd.service
