#!/usr/bin/env bash

DIR="$XDG_CONFIG_HOME/shell/shell-functions"
for file in "$DIR"/*.sh; do
    [ -r "$file" ] || continue
    # shellcheck source=/dev/null
    source "$file"
done

mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

hist() {
    history | grep -i "$1"
}

ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

serve() {
    local port=${1:-8000}
    echo "Serving on http://localhost:$port"
    python3 -m http.server "$port"
}

colors() {
    for i in {0..255}; do
        printf '\e[48;5;%dm%3d ' "$i" "$i"
        (((i + 1) % 10 == 0)) && printf '\e[0m\n'
    done
    printf '\e[0m\n'
}

path() {
    echo "$PATH" | tr ":" "\n"
}

tre() {
    tree -aC -I '.git|node_modules|vendor|__pycache__' --dirsfirst "$@" | less -FRNX
}

trash() {
    local trash_dir="$HOME/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    mv "$@" "$trash_dir"
}

ports() {
    lsof -iTCP -sTCP:LISTEN -P -n
}

extract-ip() {
    grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "$1" | sort -u
}

gscp() {
    if [ -z "$*" ]; then
        git add . && git commit && git push
    else
        git add . && git commit -m "$*" && git push
    fi
}
