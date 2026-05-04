#!/usr/bin/env bash
# Export the future standalone thememanager repo and verify it independently.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

DEST="${1:-}"
if [[ -z "$DEST" ]]; then
    error "Usage: export-thememanager.sh <destination>"
    exit 64
fi

SOURCE="${DOTS_DIR}/tools/thememanager"
DEST="$(realpath -m -- "$DEST")"

if [[ "$DEST" == "$SOURCE" || "$DEST" == "$SOURCE/"* ]]; then
    error "Destination must be outside ${SOURCE}"
    exit 64
fi

if [[ -e "$DEST" ]]; then
    error "Destination already exists: ${DEST}"
    exit 64
fi

mkdir -p "$(dirname -- "$DEST")"
cp -a "$SOURCE" "$DEST"

cleanup_export_artifacts() {
    rm -rf \
        "${DEST}/build" \
        "${DEST}/src/thememanager.egg-info" \
        "${DEST}/src/__pycache__" \
        "${DEST}/src/color256/__pycache__"
}
trap cleanup_export_artifacts EXIT

info "Exported thememanager to ${DEST}"

if ! command -v just &>/dev/null; then
    error "Missing just. Cannot run exported repo CI."
    exit 1
fi

build_out="$(mktemp -d)"
trap 'cleanup_export_artifacts; rm -rf "$build_out"' EXIT

info "Running exported CI..."
THEMEMANAGER_BUILD_DIR="$build_out" just -f "${DEST}/justfile" ci

success "Thememanager export is buildable and tested."
