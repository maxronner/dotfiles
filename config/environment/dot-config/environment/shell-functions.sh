#!/usr/bin/env bash

v() {
  local session_name=""
  if command -v tmux >/dev/null 2>&1; then
    session_name=$(tmux display-message -p '#S' 2>/dev/null)
  fi

  if [ -z "$session_name" ] || [[ -z "$TMUX" ]]; then
    nvim "$@"
    return $?
  fi

  local nvim_socket_dir="${XDG_RUNTIME_DIR:-/tmp}/nvim-sockets"
  mkdir -p "$nvim_socket_dir"
  chmod 700 "$nvim_socket_dir"

  local nvim_listen_addr="$nvim_socket_dir/nvim-$session_name.sock"
  if [[ -S "$nvim_listen_addr" ]]; then
    if nvim --server "$nvim_listen_addr" --headless --remote-expr "1" >/dev/null 2>&1; then
      local nvim_window_id=""
      nvim_window_id=$(tmux list-windows -t "$session_name" \
        -F '#{window_id} #{pane_current_command}' \
        -f '#{==:#{pane_current_command},nvim}' 2>/dev/null | \
        awk 'NR==1 {print $1}')
      if [[ -z "$nvim_window_id" ]]; then
        printf '\e[1;31m%s\e[0m: %s %s\n' 'error' 'connection refused' "$nvim_listen_addr"
        return 1
      fi
      tmux switch-client -t "$nvim_window_id" && return 0
    else
      echo "nvim not responding, removing socket"
      rm -f "$nvim_listen_addr"
    fi
  fi
  nvim --listen "$nvim_listen_addr" "$@"
  return $?
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

_getclip() {
  CLIP=()
  if command -v wl-copy >/dev/null 2>&1; then
    CLIP=(wl-copy)
  elif command -v xclip >/dev/null 2>&1; then
    CLIP=(xclip -selection clipboard)
  elif command -v pbcopy >/dev/null 2>&1; then
    CLIP=(pbcopy)
  else
    echo "No clipboard tool found (wl-copy, xclip, pbcopy)" >&2
    return 1
  fi
  printf '%s ' "${CLIP[@]}"
}

niceclip() {
  if ! cmd_script="$(_getclip)"; then
    return 1
  fi
  nicecat "$@" | eval "$cmd_script"
}

treeclip() {
  if ! cmd_script="$(_getclip)"; then
    return 1
  fi
  treecat "${1:-.}" | eval "$cmd_script"
}
