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

info "Running exported tests..."
python3 "${DEST}/tests/test_thememanager.py"

build_out="$(mktemp -d)"
trap 'cleanup_export_artifacts; rm -rf "$build_out"' EXIT

info "Building exported package..."
if command -v uv &>/dev/null; then
    uv build "$DEST" --out-dir "$build_out" >/dev/null
elif python3 -m build --version &>/dev/null; then
    python3 -m build "$DEST" --outdir "$build_out" >/dev/null
else
    error "Missing uv or python build module. Cannot verify exported package build."
    exit 1
fi

if ! compgen -G "${build_out}/thememanager-*.whl" >/dev/null; then
    error "Exported wheel was not produced"
    exit 1
fi

if ! compgen -G "${build_out}/thememanager-*.tar.gz" >/dev/null; then
    error "Exported source distribution was not produced"
    exit 1
fi

success "Thememanager export is buildable and tested."
