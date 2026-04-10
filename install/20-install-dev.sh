#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

pkg_file="${REPO_ROOT}/optional/development/pkg.txt"
mapfile -t PKGS < <(grep -v '^\s*#' "$pkg_file" | grep -v '^\s*$' | grep -v '^aur:' | sort -u)

info "Installing development packages..."
install_repo_packages "${PKGS[@]}"
