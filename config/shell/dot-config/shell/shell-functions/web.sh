clai() {
  if [[ -n "$CLAI_KEY" ]]; then
    key=$CLAI_KEY
  else
    case "$CLAI_PROVIDER" in
      "gemini")
        key="$(pass Credentials/keys/gemini)"
        ;;
      "claude")
        key="$(pass Credentials/keys/claude)"
        ;;
      "openai")
        key="$(pass Credentials/keys/openai)"
        ;;
      *)
        echo "fatal: key can not be inferred for CLAI_PROVIDER '$CLAI_PROVIDER'" >&2
        return 1
        ;;
    esac
  fi
  CLAI_KEY="$key" \
    "$HOME/.local/bin/clai" "$@"
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
