#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

info "Initializing nvim submodule..."
git -C "${REPO_ROOT}" submodule update --init apps/nvim/dot-config/nvim

info "Stowing nvim..."
stow --dotfiles --ignore="$STOW_IGNORE" -d "$APPS_DIR" -t "$HOME_DIR" nvim
