#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

AUR_PKGS=(
  tofi
  rose-pine-cursor
  yt-x
  zen-browser-bin
)

info "Installing AUR packages..."
"${AUR_HELPER[@]}" "${AUR_PKGS[@]}"

