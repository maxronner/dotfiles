#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

SYSTEM_SERVICES=(
  avahi-daemon.service
	bluetooth.service
	sshd.service
	systemd-resolved.service
	systemd-timesyncd.service
  systemd-tmpfiles-clean.timer
)

USER_SERVICES=(
  mako.service
	syncthing.service
  systemd-tmpfiles-clean.timer
)

HOME_DIR="${HOME:-/home/$(whoami)}"

info "Enabling required systemd system services..."
sudo systemctl enable --now "${SYSTEM_SERVICES[@]}"

info "Enabling required user system services..."
systemctl --user enable --now "${USER_SERVICES[@]}"

info "Enabling all user services in ${HOME_DIR}/.config/systemd/user... (ignoring templated services)"
# Use array to handle service files with spaces safely
mapfile -t user_service_files < <(find "${HOME_DIR}/.config/systemd/user" -maxdepth 1 -name "*.service" -not -name "*@.service")
if [[ ${#user_service_files[@]} -gt 0 ]]; then
  systemctl --user enable --now "${user_service_files[@]}"
else
  warn "No user services found to enable."
fi

