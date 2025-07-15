#!/bin/bash

NVIM_SOCKET_DIR="${XDG_RUNTIME_DIR:-/tmp}/nvim-sockets"
mkdir -p "$NVIM_SOCKET_DIR"

tmux list-sessions -F '#{session_name}' | while read -r TMUX_SESSION; do
  NVIM_LISTEN_ADDR="$NVIM_SOCKET_DIR/nvim-$TMUX_SESSION.sock"
  if [ -S "$NVIM_LISTEN_ADDR" ]; then
    echo "Attempting to reload theme for Neovim instance in session: $TMUX_SESSION"
    nvim --server "$NVIM_LISTEN_ADDR" --remote-expr 'execute("ReloadTheme")'
  else
    echo "No Neovim socket found for session: $TMUX_SESSION at $NVIM_LISTEN_ADDR"
  fi
done

