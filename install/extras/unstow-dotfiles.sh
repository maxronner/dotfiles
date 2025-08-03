#!/usr/bin/env bash
set -euo pipefail

STOW_CONFIG_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/config"
STOW_DEVICES_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/devices"
ENV="${1:-}"

echo "Unstowing all general dotfiles from $HOME..."
for dir in "$STOW_CONFIG_DIR"/*; do
    if [ -d "$dir" ]; then
        echo "Unstowing $(basename "$dir")..."
        stow --dotfiles --delete -d "$STOW_CONFIG_DIR" -t "$HOME" "$(basename "$dir")"
    fi
done

if [[ -n "$ENV" ]]; then
    echo "Unstowing $ENV specific dotfiles from devices..."
    stow --dotfiles --delete -d "$STOW_DEVICES_DIR" -t "$HOME" "$ENV"
else
    echo "env is not set, skipping env-specific unstow."
fi

