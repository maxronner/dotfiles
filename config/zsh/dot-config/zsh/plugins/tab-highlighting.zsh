#!/usr/bin/env zsh

autoload -Uz compinit && compinit

bindkey '^[[Z' reverse-menu-complete
bindkey '^I'   menu-complete

# Use menu selection with highlighted items
zstyle ':completion:*' menu select

zstyle ':completion:*' format ''

# Enable colors for completion matches
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better layout
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' verbose yes
