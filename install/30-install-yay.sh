#!/usr/bin/env bash

if ! command -v yay > /dev/null; then
    echo "yay not found. Installing yay...";
    git clone https://aur.archlinux.org/yay.git "${HOME}"/yay && cd "${HOME}"/yay && makepkg -s --noconfirm;
    sudo pacman -U --noconfirm --needed "$(find "${HOME}"/yay -name "*.pkg.tar.zst" | head -n 1)";
    rm -rf "${HOME}"/yay;
fi
