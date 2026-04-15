#!/usr/bin/env bash
# scope: system
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

pkg_file="${REPO_ROOT}/optional/development/pkg.txt"

if [[ ! -f "$pkg_file" ]]; then
  error "Development package manifest not found: ${pkg_file}"
  exit 1
fi

mapfile -t PKGS < <(grep -v '^\s*#' "$pkg_file" | grep -v '^\s*$' | grep -v '^aur:' | sort -u)

info "Installing development packages..."
install_repo_packages "${PKGS[@]}"
