#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

SYSTEM_SERVICES=(
    avahi-daemon.service
	bluetooth.service
	sshd.service
	systemd-resolved.service
	systemd-timesyncd.service
)

USER_SERVICES=(
    mako.service
	syncthing.service
)

HOME_DIR="${HOME:-/home/$(whoami)}"

info "Enabling generic systemd system services..."
sudo systemctl enable --now "${SYSTEM_SERVICES[@]}"

info "Enabling specific user systemd services..."
systemctl --user enable --now "${USER_SERVICES[@]}"

info "Enabling all user services in ${HOME_DIR}/.config/systemd/user..."
# Use array to handle service files with spaces safely
mapfile -t user_service_files < <(find "${HOME_DIR}/.config/systemd/user" -maxdepth 1 -name "*.service")
if [[ ${#user_service_files[@]} -gt 0 ]]; then
  systemctl --user enable --now "${user_service_files[@]}"
else
  warn "No user services found to enable."
fi

