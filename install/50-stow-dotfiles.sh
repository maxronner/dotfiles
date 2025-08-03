#!/bin/bash
set -e

STOW_DIR="$(dirname $(dirname $(readlink -f "$0")))/config"
DEST_DIR="/home/$(whoami)"

echo "Stowing dotfiles from $STOW_DIR to $DEST_DIR..."
for dir in "$STOW_DIR"/*; do
	if [ -d "$dir" ]; then
		echo "Stowing $(basename "$dir")..."
		stow --dotfiles -d "$STOW_DIR" -t "$DEST_DIR" "$(basename "$dir")"
	fi
done
