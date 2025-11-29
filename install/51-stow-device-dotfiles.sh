#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

env="${1:-}"

if [[ -z "$env" ]]; then
    warn "env is not set, nothing to do."
    exit 0
fi

BASE_DIR="$(dirname "$(readlink -f "$0")")/../"
HOME_DIR="$HOME"

info "Installing $env specific dotfiles..."
stow --dotfiles -d "${BASE_DIR}devices" -t "${HOME_DIR}" "$env"

