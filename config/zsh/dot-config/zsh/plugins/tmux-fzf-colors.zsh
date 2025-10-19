#!/usr/bin/env zsh

# Sync FZF_DEFAULT_OPTS from tmux environment when inside tmux
function sync-fzf-opts-from-tmux() {
  [[ -z "$TMUX" ]] && return
  local tmux_val
  tmux_val=$(tmux show-environment -g FZF_DEFAULT_OPTS 2>/dev/null | sed 's/^FZF_DEFAULT_OPTS=//')
  [[ -n "$tmux_val" && "$FZF_DEFAULT_OPTS" != "$tmux_val" ]] && export FZF_DEFAULT_OPTS="$tmux_val"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd sync-fzf-opts-from-tmux
