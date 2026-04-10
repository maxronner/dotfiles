#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

bash "${REPO_ROOT}/install/30-install-yay.sh"
bash "${REPO_ROOT}/install/31-install-aur.sh" "$PROFILE"
