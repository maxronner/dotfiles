#!/usr/bin/env bash

v() {
  if command -v tmux >/dev/null 2>&1; then
    TMUX_SESSION=$(tmux display-message -p '#S')
    if [ -n "$TMUX_SESSION" ]; then
      NVIM_SOCKET_DIR="${XDG_RUNTIME_DIR:-/tmp}/nvim-sockets"
      mkdir -p "$NVIM_SOCKET_DIR"
      NVIM_LISTEN_ADDR="$NVIM_SOCKET_DIR/nvim-$TMUX_SESSION.sock"
      if [ -S "$NVIM_LISTEN_ADDR" ]; then
        printf '\e[1;31m%s\e[0m: %s %s\n' 'v' 'nvim socket already exists at' "$NVIM_LISTEN_ADDR" >&2
        return 1
      fi
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

treecat() {
  local dir="${1:-.}"
  local find_cmd

  if command -v fd >/dev/null 2>&1; then
    find_cmd=(fd -t f -0 -E .git --color=never . "$dir")
  else
    find_cmd=(find "$dir" -path "$dir/.git" -prune -o -type f -print0)
  fi

  "${find_cmd[@]}" |
    sort -z |
    xargs -0 awk '
      FNR==1 {
        # Print separation between files, but not before the very first file of the batch
        if (NR > 1) print "\n\n"
        printf "===== %s =====\n", FILENAME
      }
      { print }
      # Ensure the last file in the batch gets trailing newlines
      END { print "\n\n" }
    '
}

treeclip() {
  DIR="${1:-.}"
  CLIP=()
  if command -v wl-copy >/dev/null 2>&1; then
    CLIP=(wl-copy)
  elif command -v xclip >/dev/null 2>&1; then
    CLIP=(xclip -selection clipboard)
  elif command -v pbcopy >/dev/null 2>&1; then
    CLIP=(pbcopy)
  else
    echo "No clipboard tool found (wl-copy, xclip, pbcopy)" >&2
    exit 1
  fi
  treecat "$DIR" | "${CLIP[@]}"
}
