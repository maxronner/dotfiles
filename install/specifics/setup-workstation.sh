#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

readonly WORKSPACE_PKGS=(
  gamescope
  gamemode
  steam
  swayfx
)

install_aur_packages "${WORKSPACE_PKGS[@]}"
