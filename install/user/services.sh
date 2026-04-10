#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

USER_SERVICES=(
  mako.service
  syncthing.service
)

info "Enabling managed user services..."
for unit in "${USER_SERVICES[@]}"; do
  if ! systemctl --user cat "$unit" &>/dev/null; then
    error "Unit file not found: ${unit} — is the package installed and dotfiles stowed?"
    exit 1
  fi
done

systemctl --user enable --now "${USER_SERVICES[@]}"
success "User services enabled."
