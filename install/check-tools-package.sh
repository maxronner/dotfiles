#!/usr/bin/env bash
# Verify package-ready tools build without writing artifacts into the repo.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/tool-source.sh"

build_thememanager() {
    local tool_dir
    local out_dir
    tool_dir="$(resolve_thememanager_build_source)"
    out_dir="$(mktemp -d)"
    cleanup() {
        rm -rf "$out_dir" \
            "${tool_dir}/build" \
            "${tool_dir}/src/thememanager.egg-info" \
            "${tool_dir}/src/__pycache__" \
            "${tool_dir}/src/color256/__pycache__"
    }
    trap cleanup RETURN

    if command -v just &>/dev/null && [[ -f "${tool_dir}/justfile" ]]; then
        THEMEMANAGER_BUILD_DIR="$out_dir" just -f "${tool_dir}/justfile" build >/dev/null
    elif command -v uv &>/dev/null; then
        uv build "$tool_dir" --out-dir "$out_dir" >/dev/null
    elif python3 -m build --version &>/dev/null; then
        python3 -m build "$tool_dir" --outdir "$out_dir" >/dev/null
    else
        error "Missing uv or python build module. Cannot verify tool package build."
        return 1
    fi

    if ! compgen -G "${out_dir}/thememanager-*.whl" >/dev/null; then
        error "thememanager wheel was not produced"
        return 1
    fi

    if ! compgen -G "${out_dir}/thememanager-*.tar.gz" >/dev/null; then
        error "thememanager source distribution was not produced"
        return 1
    fi
}

build_thememanager
success "Tool packages build."
