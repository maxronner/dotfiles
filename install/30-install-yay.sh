#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

if ! command -v yay > /dev/null; then
    local_yay_dir="${HOME}/yay"
    info "yay not found. Installing yay..."
    trap 'rm -rf "$local_yay_dir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$local_yay_dir"
    (
        cd "$local_yay_dir"
        makepkg -si --noconfirm
    )
fi
