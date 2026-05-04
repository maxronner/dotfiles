#!/usr/bin/env bash
# Install package-ready local tools without changing dotfile stow behavior.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/tool-source.sh"

install_thememanager() {
    local install_spec
    local source_label
    install_spec="$(resolve_thememanager_install_spec)"
    source_label="$(describe_thememanager_install_spec "$install_spec")"

    if command -v uv &>/dev/null; then
        info "Installing thememanager from ${source_label} with uv tool: ${install_spec}"
        uv tool install --force --reinstall "$install_spec"
        return 0
    fi

    if command -v pipx &>/dev/null; then
        info "Installing thememanager from ${source_label} with pipx: ${install_spec}"
        pipx install --force "$install_spec"
        return 0
    fi

    error "Missing uv or pipx. Install one to package-install local tools."
    return 1
}

install_thememanager
