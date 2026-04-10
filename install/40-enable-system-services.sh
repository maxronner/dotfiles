#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

SYSTEM_SERVICES=(
  systemd-resolved.service
  systemd-timesyncd.service
  systemd-tmpfiles-clean.timer
)

info "Enabling required systemd system services..."
sudo systemctl enable --now "${SYSTEM_SERVICES[@]}"
