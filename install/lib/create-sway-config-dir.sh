#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

SCRIPTS_DIR="${HOME_DIR}/.config/sway/scripts"

if [[ -d "$SCRIPTS_DIR" ]]; then
    info "Sway scripts directory already exists, skipping..."
    exit 0
fi

info "Creating sway config directory structure..."
mkdir -p "$SCRIPTS_DIR"
