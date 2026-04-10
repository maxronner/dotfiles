#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

SYSTEM_SERVICES=(
  systemd-resolved.service
  systemd-timesyncd.service
  systemd-tmpfiles-clean.timer
)

USER_SERVICES=(
  mako.service
  syncthing.service
)

USER_TIMERS=()

info "Enabling required systemd system services..."
sudo systemctl enable --now "${SYSTEM_SERVICES[@]}"

info "Enabling required user system services..."
systemctl --user enable --now "${USER_SERVICES[@]}"

info "Enabling all standalone user services in ${HOME_DIR}/.config/systemd/user... (ignoring templated services)"
# Use arrays to handle service files with spaces safely
mapfile -t user_service_files < <(find "${HOME_DIR}/.config/systemd/user" -maxdepth 1 -name "*.service" -not -name "*@*.service")
standalone_user_service_files=()
for service_file in "${user_service_files[@]}"; do
  timer_file="${service_file%.service}.timer"
  if [[ -e "${timer_file}" ]]; then
    continue
  fi

  standalone_user_service_files+=("${service_file}")
done

if [[ ${#standalone_user_service_files[@]} -gt 0 ]]; then
  systemctl --user enable --now "${standalone_user_service_files[@]}"
else
  warn "No standalone user services found to enable."
fi

info "Enabling all user timers in ${HOME_DIR}/.config/systemd/user... (ignoring templated timers)"
mapfile -t user_timer_files < <(find "${HOME_DIR}/.config/systemd/user" -maxdepth 1 -name "*.timer" -not -name "*@.timer")
if [[ ${#user_timer_files[@]} -gt 0 ]]; then
  systemctl --user enable --now "${user_timer_files[@]}"
else
  warn "No user timers found to enable."
fi
