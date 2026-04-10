#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

env="${1:-}"

if [[ -z "$env" ]]; then
    warn "env is not set, nothing to do."
    exit 0
fi

info "Installing $env specific dotfiles..."
stow --dotfiles --no-folding --ignore='^(pkg\.txt|\.gitignore)$' -d "${REPO_ROOT}/devices" -t "${HOME_DIR}" "$env"
