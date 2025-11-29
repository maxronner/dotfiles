#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

PASSDIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

info "Securing permissions on: $PASSDIR"
chown -R "$USER":"$USER" "$PASSDIR"

find "$PASSDIR" -type d -exec chmod 0700 {} +
find "$PASSDIR" -type f -exec chmod 0600 {} +

success "Permissions secured (dirs: 0700, files: 0600)"

