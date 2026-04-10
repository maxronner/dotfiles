#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

SWAY_CONFIG_DIR="$HOME/.config/sway"
SCRIPTS_DIR="$SWAY_CONFIG_DIR/scripts"

if [[ -d "$SWAY_CONFIG_DIR" ]]; then
    info "Sway config directory already exists, skipping..."
    exit 0
fi

info "Creating sway config directory structure..."
mkdir -p "$SCRIPTS_DIR"
