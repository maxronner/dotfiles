#!/usr/bin/env bash
set -e

echo "Installing TPM (tmux package manager)..."
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
	git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi
