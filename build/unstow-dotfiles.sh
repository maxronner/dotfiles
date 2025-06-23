#!/usr/bin/env bash
set -e

STOW_DIR="$(dirname $(dirname $(readlink -f "$0")))/config"

echo "Unstowing dotfiles from $HOME..."
for dir in "$STOW_DIR"/*; do
	if [ -d "$dir" ]; then
		echo "Unstowing $(basename "$dir")..."
		stow --dotfiles --delete -d "$STOW_DIR" -t "$HOME" "$(basename "$dir")"
	fi
done
