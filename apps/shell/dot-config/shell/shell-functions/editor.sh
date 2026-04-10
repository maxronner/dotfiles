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
