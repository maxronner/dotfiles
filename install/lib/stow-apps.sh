#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

STOW_DIR="${REPO_ROOT}/apps"
DEST_DIR="${HOME_DIR}"

info "Stowing system dotfiles from $STOW_DIR to $DEST_DIR..."
for dir in "$STOW_DIR"/*; do
    if [[ -d "$dir" ]]; then
        name="$(basename "$dir")"
        [[ "$name" == "nvim" ]] && continue  # opt-in via stow-nvim
        info "Stowing ${name}..."
        stow --dotfiles --no-folding --ignore='^(pkg\.txt|\.gitignore)$' -d "$STOW_DIR" -t "$DEST_DIR" "$name"
    fi
done
