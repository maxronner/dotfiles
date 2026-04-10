#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

info "Initializing git submodules..."
if ! git -C "${REPO_ROOT}" submodule update --init --recursive; then
  warn "Failed to fetch submodules (network issue?), continuing with existing state"
fi
