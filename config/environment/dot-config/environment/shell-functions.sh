#!/usr/bin/env bash

v() {
    if command -v tmux >/dev/null 2>&1; then
        TMUX_SESSION=$(tmux display-message -p '#S')
        if [ -n "$TMUX_SESSION" ]; then
            NVIM_SOCKET_DIR="${XDG_RUNTIME_DIR:-/tmp}/nvim-sockets"
            mkdir -p "$NVIM_SOCKET_DIR"
            NVIM_LISTEN_ADDR="$NVIM_SOCKET_DIR/nvim-$TMUX_SESSION.sock"
            nvim --listen "$NVIM_LISTEN_ADDR" "$@"
        else
            nvim "$@"
        fi
    else
        nvim "$@"
    fi
}

lcount() {
    find "${1:-.}" \
        -type f \
        -not -path '*/.git/*' \
        -exec wc -l {} + |
        sort -n
}
