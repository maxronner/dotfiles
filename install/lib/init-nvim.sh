#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

STOW_DIR="${REPO_ROOT}/apps"
DEST_DIR="${HOME_DIR}"

info "Initializing nvim submodule..."
git -C "${REPO_ROOT}" submodule update --init apps/nvim/dot-config/nvim

info "Stowing nvim to ${DEST_DIR}..."
stow --dotfiles --ignore='^(pkg\.txt|\.gitignore)$' -d "$STOW_DIR" -t "$DEST_DIR" nvim
