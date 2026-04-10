#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

if [[ -z "$PROFILE" ]]; then
    info "No device profile specified, skipping device setup."
    exit 0
fi

SETUP_SCRIPT="${SCRIPT_DIR}/../specifics/setup-${PROFILE}.sh"

if [[ ! -f "$SETUP_SCRIPT" ]]; then
    warn "No device setup script for profile: ${PROFILE}"
    exit 0
fi

info "Running device setup for profile: ${PROFILE}..."
bash "$SETUP_SCRIPT"
