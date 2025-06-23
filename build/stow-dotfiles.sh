#!/bin/bash
set -e

STOW_DIR="$(dirname $(dirname $(readlink -f "$0")))/config"
HOME_DIR="/home/$(whoami)"

echo "Stowing dotfiles from $STOW_DIR to $HOME_DIR..."
for dir in "$STOW_DIR"/*; do
	if [ -d "$dir" ]; then
		echo "Stowing $(basename "$dir")..."
		stow --dotfiles -d "$STOW_DIR" -t "$HOME_DIR" "$(basename "$dir")"
	fi
done
