ai() {
  if [[ -z "$LLM_PROVIDER" ]]; then
    echo "error: LLM_PROVIDER is not set" >&2
    return 1
  fi
  ai-run "$LLM_PROVIDER" clai "$@"
}

fman() {
  man -k . | \
    fzf -q "$1" --prompt='man> ' --preview $'echo {} | tr -d \'()\' |
    awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx |
    bat -l man -p --color always' | \
    tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
  }

cht() {
  local q="$*"
  curl -s https://cht.sh/:list \
    | fzf --query="$q" \
    --select-1 --exit-0 \
    --preview 'curl -s https://cht.sh/{1}' \
    --bind 'enter:execute(curl -s https://cht.sh/{})+abort'
  local rc=$?
  (( rc == 130 )) && rc=0
  return "$rc"
}
