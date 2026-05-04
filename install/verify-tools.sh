#!/usr/bin/env bash
# Verify local tool commands are callable after stow or package install.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

verify_command() {
    local command_name="$1"
    shift

    if ! PATH="${DOTS_TOOL_VERIFY_PATH:-$PATH}" command -v "$command_name" &>/dev/null; then
        error "Missing command: ${command_name}"
        return 1
    fi

    PATH="${DOTS_TOOL_VERIFY_PATH:-$PATH}" "$command_name" "$@" >/dev/null
}

verify_command thememanager --help
verify_command color256 --help

if ! PATH="${DOTS_TOOL_VERIFY_PATH:-$PATH}" command -v theme-apply-all &>/dev/null; then
    error "Missing command: theme-apply-all"
    exit 1
fi

XDG_RUNTIME_DIR="${DOTS_TOOL_VERIFY_RUNTIME_DIR:-/tmp}" \
    PATH="${DOTS_TOOL_VERIFY_PATH:-$PATH}" \
    theme-apply-all --check >/dev/null

success "Tool commands are available."
