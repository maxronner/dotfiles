#!/usr/bin/env bash
# Vendor the standalone thememanager repo into the bundled bootstrap fallback.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/tool-source.sh"

SOURCE="$(resolve_thememanager_standalone_source)"
DEST="${DOTS_DIR}/tools/thememanager"

if [[ "$(realpath -m -- "$SOURCE")" == "$(realpath -m -- "$DEST")" ]]; then
    error "Standalone source must be outside bundled fallback: ${DEST}"
    exit 64
fi

if ! git -C "$SOURCE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    error "Standalone source is not a git worktree: ${SOURCE}"
    exit 1
fi

if [[ -n "$(git -C "$SOURCE" status --porcelain)" ]]; then
    error "Standalone thememanager repo is dirty: ${SOURCE}"
    git -C "$SOURCE" status --short >&2
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    error "Missing rsync. Cannot vendor thememanager."
    exit 1
fi

info "Vendoring thememanager from ${SOURCE}"
rsync -a --delete \
    --exclude='.git/' \
    --exclude='build/' \
    --exclude='dist/' \
    --exclude='src/thememanager.egg-info/' \
    --exclude='__pycache__/' \
    --exclude='*.pyc' \
    "${SOURCE}/" "${DEST}/"

if ! command -v just >/dev/null 2>&1; then
    error "Missing just. Cannot verify vendored thememanager."
    exit 1
fi

info "Running bundled tool tests..."
just -f "${DOTS_DIR}/justfile" test-tools

success "Vendored thememanager fallback is up to date."
