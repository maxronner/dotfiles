#!/bin/bash
set -e
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

STOW_DIR="$(dirname $(dirname $(readlink -f "$0")))/config"
DEST_DIR="/home/$(whoami)"

info "Stowing dotfiles from $STOW_DIR to $DEST_DIR..."
for dir in "$STOW_DIR"/*; do
	if [ -d "$dir" ]; then
		info "Stowing $(basename "$dir")..."
		stow --dotfiles -d "$STOW_DIR" -t "$DEST_DIR" "$(basename "$dir")"
	fi
done
