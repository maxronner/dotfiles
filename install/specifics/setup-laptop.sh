#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

readonly LAPTOP_PKGS=(
    kmonad
    sway
)

install_aur_packages "${LAPTOP_PKGS[@]}"

info "Allow uinput access for kmonad"
sudo tee /etc/udev/rules.d/90-uinput.rules <<'EOF'
KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
EOF

info "Adding user to input group"
sudo usermod -aG input "$USER"

sudo udevadm control --reload-rules
sudo udevadm trigger
