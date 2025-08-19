#!/usr/bin/env bash

if ! command -v yay > /dev/null; then
    echo "yay not found. Installing yay...";
    git clone https://aur.archlinux.org/yay.git "${HOME}"/yay && cd "${HOME}"/yay && makepkg -si --noconfirm;
    rm -rf "${HOME}"/yay;
fi
