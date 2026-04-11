#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

USER_SERVICES=(
  mako.service
  syncthing.service
  waybar.service
)

USER_UNITS_REQUIRED=(
  sway-session.target
)

info "Validating managed user units..."
for unit in "${USER_SERVICES[@]}" "${USER_UNITS_REQUIRED[@]}"; do
  if ! systemctl --user cat "$unit" &>/dev/null; then
    error "Unit file not found: ${unit} — is the package installed and dotfiles stowed?"
    exit 1
  fi
done

info "Enabling managed user services..."
systemctl --user enable --now "${USER_SERVICES[@]}"
success "User services enabled."
