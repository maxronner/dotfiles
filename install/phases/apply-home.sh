#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

bash "${SCRIPT_DIR}/stow-dotfiles.sh" "$PROFILE"
bash "${SCRIPT_DIR}/stow-scripts.sh"
