#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

ENV="${1:-}"

collect_pkg_entries repo "$ENV" PKGS

install_repo_packages "${PKGS[@]}"

info "Symlinking vim-spell-sv to $HOME/.local/share/nvim/site/spell"
mkdir -p ~/.local/share/nvim/site/spell
stow -d /usr/share/vim/vimfiles -t "$HOME/.local/share/nvim/site/spell" spell

mkdir -p ~/.local/share/zsh
