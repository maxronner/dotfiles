#!/usr/bin/env zsh

# Use menu selection with highlighted items
zstyle ':completion:*' menu select

zstyle ':completion:*' format ''

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Enable colors for completion matches
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better layout
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' verbose yes
