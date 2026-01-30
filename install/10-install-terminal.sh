#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

CLI_PKGS=(
  7zip
  age
  alsa-utils
  astroterm
  atac
  base-devel
  bash-completion
  bat
  bluetui
  btop
  chafa
  dosfstools
  duf
  dust
  eza
  fastfetch
  fd
  feh
  fzf
  gammastep
  ghostty
  git
  gitui
  git-delta
  glow
  go
  grim
  htop
  inetutils
  inotify-tools
  imagemagick
  jq
  libnotify
  man-db
  nano
  neomutt
  neovim
  nmap
  noto-fonts
  noto-fonts-emoji
  npm
  nss-mdns
  openssh
  pacman-contrib
  pass
  pass-otp
  passff-host
  pipewire-pulse
  pulsemixer
  rclone
  ripgrep
  rsync
  ruby
  starship
  stow
  sqlite
  syncthing
  task
  taskwarrior-tui
  tealdeer
  tgpt
  tmux
  tree-sitter-cli
  ttf-hack-nerd
  vim-spell-en
  vim-spell-sv
  w3m
  wget
  wireguard-tools
  unzip
  yazi
  zig
  zk
  zoxide
  zsh
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

info "Installing CLI/Environment packages..."
"${PACKAGE_MANAGER[@]}" "${CLI_PKGS[@]}"

info "Symlinking vim-spell-sv to $HOME/.local/share/nvim/site/spell"
mkdir -p ~/.local/share/nvim/site/spell
stow -d /usr/share/vim/vimfiles -t "$HOME/.local/share/nvim/site/spell" spell

bash "$(dirname "${BASH_SOURCE[0]}")/11-install-tpm.sh"
