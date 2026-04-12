#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Stow themes and symlink local scripts/libs
bash "${SCRIPT_DIR}/../lib/stow-scripts.sh"

# Create sway config directory if absent
bash "${SCRIPT_DIR}/../lib/create-sway-config-dir.sh"

# Install TPM if absent
bash "${SCRIPT_DIR}/../lib/install-tpm.sh"

# Prepare user-facing runtime layout for installed software
info "Setting up vim spell symlinks..."
mkdir -p "${HOME_DIR}/.local/share/nvim/site/spell"
stow -d /usr/share/vim/vimfiles -t "${HOME_DIR}/.local/share/nvim/site/spell" spell

info "Creating zsh data directory..."
mkdir -p "${HOME_DIR}/.local/share/zsh"

# Seed palette if no live palette exists, then render themed configs
info "Applying theme from palette..."
THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_SEED="${XDG_CONFIG_HOME:-$HOME/.config}/thememanager/palette.seed.json"
mkdir -p "$THEME_DATA_DIR"
if [[ ! -f "$THEME_DATA_DIR/palette.json" ]] && [[ -f "$PALETTE_SEED" ]]; then
    cp "$PALETTE_SEED" "$THEME_DATA_DIR/palette.json"
fi

# Seed ghostty default theme so ghostty has a baseline before theme-apply-all
GHOSTTY_THEME_SEED="${REPO_ROOT}/apps/ghostty/dot-config/ghostty/themes/color256-theme"
GHOSTTY_THEME_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes/color256-theme"
if [[ -f "$GHOSTTY_THEME_SEED" ]] && [[ ! -f "$GHOSTTY_THEME_DEST" ]]; then
    mkdir -p "$(dirname "$GHOSTTY_THEME_DEST")"
    cp "$GHOSTTY_THEME_SEED" "$GHOSTTY_THEME_DEST"
fi

theme-apply-all
