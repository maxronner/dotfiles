#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

DESKTOP_PKGS=(
  autotiling
  blueman
  chromium
  cmatrix
  firefox
  flatpak
  foot
  gimp
  gnome-themes-extra
  ly
  mako
  mpv
  pavucontrol
  slurp
  swaybg
  swayidle
  swaylock
  ttf-jetbrains-mono-nerd
  vlc
  waybar
  wl-clipboard
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
)

echo "Installing Desktop packages..."
"${PACKAGE_MANAGER[@]}" "${DESKTOP_PKGS[@]}"
