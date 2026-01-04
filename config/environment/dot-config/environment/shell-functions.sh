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
    if command -v fd >/dev/null 2>&1; then
        fd -t f -E .git "${1:-.}" -X wc -l | sort -n
    else
        find "${1:-.}" \
            -type f \
            -not -path '*/.git/*' \
            -exec wc -l {} + |
            sort -n
    fi
}

fman() {
    man -k . | \
        fzf -q "$1" --prompt='man> ' --preview $'echo {} | tr -d \'()\' |
            awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx |
            bat -l man -p --color always' | \
        tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}

get() {
    yay -Slq | fzf -q "$1" -m --preview 'yay -Si {1}'| xargs -ro yay -S

}
del() {
    yay -Qq | fzf -q "$1" -m --preview 'yay -Qi {1}' | xargs -ro yay -Rns
}

fzf-nvim() {
    fzf --tmux "$FZF_TMUX_PANE_OPTS" --prompt='nvim> ' --multi --bind 'enter:become(nvim {+})'
}

# Ripgrep current directory with fzf
fzf-rg() {
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    INITIAL_QUERY="${*:-}"
    fzf --tmux "$FZF_TMUX_PANE_OPTS" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(nvim {1} +{2})'
    }

