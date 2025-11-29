#!/usr/bin/env bash
set -euo pipefail

if ! command -v yay > /dev/null; then
    source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
    info "yay not found. Installing yay...";
    git clone https://aur.archlinux.org/yay.git "${HOME}"/yay && cd "${HOME}"/yay && makepkg -si --noconfirm;
    rm -rf "${HOME}"/yay;
fi
