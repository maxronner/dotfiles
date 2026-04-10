#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

info "Installing TPM (tmux package manager)..."
if [[ ! -d "${HOME_DIR}/.config/tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "${HOME_DIR}/.config/tmux/plugins/tpm"
fi
