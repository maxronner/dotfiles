#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

WORKSPACE_PKGS=(
  steam
  swayfx
)

echo "Installing workstation specific packages..."
"${AUR_HELPER[@]}" "${WORKSPACE_PKGS[@]}"
