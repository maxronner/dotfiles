#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

shopt -s nullglob

info "Symlinking color256 to ${HOME_DIR}/.local..."
mkdir -p "${HOME_DIR}/.local/bin"
mkdir -p "${HOME_DIR}/.local/share/themes"

for theme_file in "${HOME_DIR}/.local/share/themes"/*.txt; do
    if [[ -L "$theme_file" ]] \
        && [[ "$(readlink -f "$theme_file")" != "$theme_file" ]] \
        && [[ "$(readlink -f "$theme_file")" == "${REPO_ROOT}/local/thememanager/color256/themes/"* ]]; then
        rm -f "$theme_file"
    fi
done

ln -sf "${REPO_ROOT}/local/dot-local/bin/color256" "${HOME_DIR}/.local/bin/color256"

for theme_file in "${REPO_ROOT}/local/thememanager/color256/themes"/*.txt; do
    if [[ -f "$theme_file" ]]; then
        ln -sf "$theme_file" "${HOME_DIR}/.local/share/themes/"
    fi
done
