#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

# Install repo packages (pacman)
bash "${SCRIPT_DIR}/../lib/install-terminal.sh" "$PROFILE"

# Bootstrap yay if absent, then install AUR packages
bash "${SCRIPT_DIR}/../lib/install-yay.sh"
bash "${SCRIPT_DIR}/../lib/install-aur.sh" "$PROFILE"
