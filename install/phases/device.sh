#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

if [[ -z "$PROFILE" ]]; then
    warn "env is not set, nothing to do."
    exit 0
fi

SETUP_SCRIPT="${REPO_ROOT}/install/specifics/setup-${PROFILE}.sh"

if [[ ! -f "$SETUP_SCRIPT" ]]; then
    warn "No device setup script for profile: ${PROFILE}"
    exit 0
fi

bash "$SETUP_SCRIPT"
