#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

# Stow app dotfiles to $HOME (skips nvim — opt-in via extras)
bash "${SCRIPT_DIR}/../lib/stow-apps.sh"

# Stow device-specific overrides if profile provided
bash "${SCRIPT_DIR}/../lib/stow-device.sh" "$PROFILE"
