#!/usr/bin/env sh

if command -v nvim >/dev/null 2>&1; then
  if ! command -v vim >/dev/null 2>&1; then
    alias vim='nvim -u NONE'
  fi

  alias nano='nvim'
  alias svim='sudo nvim'
  alias v='nvim-attach'
  alias bs='nvim --cmd "lua vim.g.startup_mode = \"scratch\""'
fi
