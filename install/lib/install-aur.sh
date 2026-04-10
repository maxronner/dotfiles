#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

ENV="${1:-}"

collect_pkg_entries aur "$ENV" AUR_PKGS

[[ ${#AUR_PKGS[@]} -eq 0 ]] && exit 0

install_aur_packages "${AUR_PKGS[@]}"
