#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

shopt -s nullglob

bash "${SCRIPT_DIR}/stow-themes.sh"

info "Stowing local scripts to ${HOME_DIR}/.local/bin..."
mkdir -p "${HOME_DIR}/.local/bin"
for script_file in "${REPO_ROOT}/local/dot-local/bin"/*; do
	if [[ -f "$script_file" ]]; then
		ln -sf "$script_file" "${HOME_DIR}/.local/bin/"
	fi
done

info "Stowing local lib to ${HOME_DIR}/.local/lib..."
mkdir -p "${HOME_DIR}/.local/lib"
for lib_file in "${REPO_ROOT}/local/dot-local/lib"/*; do
	if [[ -f "$lib_file" ]]; then
		ln -sf "$lib_file" "${HOME_DIR}/.local/lib/"
	fi
done

info "Stowing deferred scripts still under scripts/..."
for script_file in "${REPO_ROOT}/scripts/dot-local/bin"/*; do
	if [[ -f "$script_file" ]]; then
		ln -sf "$script_file" "${HOME_DIR}/.local/bin/"
	fi
done
