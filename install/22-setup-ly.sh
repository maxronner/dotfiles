#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

info "Configuring ly..."
LY_CONFIG=/etc/ly/config.ini
sudo sed -i "s/^[[:space:]]*animation[[:space:]]*=.*/animation = matrix/" "$LY_CONFIG"
sudo sed -i "s/^[[:space:]]*clock[[:space:]]*=.*/clock = %c/" "$LY_CONFIG"
sudo sed -i "s/^[[:space:]]*vi_mode[[:space:]]*=.*/vi_mode = true/" "$LY_CONFIG"
info "Overriding ly service..."
LY_OVERRIDE_DIR=/etc/systemd/system/ly.service.d
LY_OVERRIDE_FILE="$LY_OVERRIDE_DIR/override.conf"
sudo mkdir -p "$LY_OVERRIDE_DIR"
echo "[Service]" | sudo tee "$LY_OVERRIDE_FILE" > /dev/null
echo "StandardOutput=null" | sudo tee -a "$LY_OVERRIDE_FILE" > /dev/null
echo "StandardError=null" | sudo tee -a "$LY_OVERRIDE_FILE" > /dev/null
sudo systemctl daemon-reexec
info "Enabling ly service..."
sudo systemctl enable --now ly.service
sudo systemctl disable --now getty@tty2.service

