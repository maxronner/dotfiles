#!/usr/bin/env bash
# scope: system
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"
source "${SCRIPT_DIR}/../packages.sh"

pkg_file="${DOTS_DIR}/optional/development/pkg.txt"

if [[ ! -f "$pkg_file" ]]; then
  error "Development package manifest not found: ${pkg_file}"
  exit 1
fi

validate_package_manifests "$pkg_file"

collect_packages repo REPO_PKGS "$pkg_file"
collect_packages aur AUR_PKGS "$pkg_file"

info "Installing development packages..."
install_repo_packages "${REPO_PKGS[@]}"
if (( ${#AUR_PKGS[@]} > 0 )); then
  ensure_yay
fi
install_aur_packages "${AUR_PKGS[@]}"
