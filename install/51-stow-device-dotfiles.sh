#!/usr/bin/env bash
set -euo pipefail

env="${1:-}"

if [[ -z "$env" ]]; then
    echo "env is not set, nothing to do."
    exit 0
fi

BASE_DIR="$(dirname "$(readlink -f "$0")")/../"
HOME_DIR="$HOME"

echo "Installing $env specific dotfiles..."
stow --dotfiles -d "${BASE_DIR}devices" -t "${HOME_DIR}" "$env"

