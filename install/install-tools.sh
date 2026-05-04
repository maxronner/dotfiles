#!/usr/bin/env bash
# Install package-ready local tools without changing dotfile stow behavior.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/tool-source.sh"

install_thememanager() {
    local tool_dir
    local source_label
    tool_dir="$(resolve_thememanager_source)"
    source_label="$(describe_thememanager_source "$tool_dir")"

    if command -v uv &>/dev/null; then
        info "Installing thememanager from ${source_label} source with uv tool: ${tool_dir}"
        uv tool install --reinstall "$tool_dir"
        return 0
    fi

    if command -v pipx &>/dev/null; then
        info "Installing thememanager from ${source_label} source with pipx: ${tool_dir}"
        pipx install --force "$tool_dir"
        return 0
    fi

    error "Missing uv or pipx. Install one to package-install local tools."
    return 1
}

install_thememanager
