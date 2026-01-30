duck() {
  [ "$#" -gt 0 ] || { printf "Usage: ? <search terms>\n" >&2; exit 2; }
  q="$*"
  enc="$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))' "$q")" || exit 1
  w3m "https://duckduckgo.com/html/?q=$enc"
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
