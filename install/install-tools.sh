#!/usr/bin/env bash
# Install package-ready local tools without changing dotfile stow behavior.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

install_thememanager() {
    local tool_dir="${DOTS_DIR}/tools/thememanager"

    if command -v uv &>/dev/null; then
        info "Installing thememanager with uv tool..."
        uv tool install --reinstall "$tool_dir"
        return 0
    fi

    if command -v pipx &>/dev/null; then
        info "Installing thememanager with pipx..."
        pipx install --force "$tool_dir"
        return 0
    fi

    error "Missing uv or pipx. Install one to package-install local tools."
    return 1
}

install_thememanager
