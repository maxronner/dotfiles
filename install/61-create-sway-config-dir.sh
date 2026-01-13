#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

SWAY_CONFIG_DIR="$HOME/.config/sway"
SCRIPTS_DIR="$SWAY_CONFIG_DIR/scripts"

if [[ -d "$SWAY_CONFIG_DIR" ]]; then
    info "Sway config directory already exists, skipping..."
    exit 0
fi

info "Creating sway config directory structure..."
mkdir -p "$SCRIPTS_DIR"
