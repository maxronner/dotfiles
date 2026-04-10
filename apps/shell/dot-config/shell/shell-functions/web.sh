fman() {
  man -k . |
    fzf -q "$1" --prompt='man> ' --preview $'echo {}
    | tr -d \'()\'
    | awk \'{printf "%s ", $2} {print $1}\'
    | xargs -r man
    | col -bx
    | bat -l man -p --color always' |
    tr -d '()' |
    awk '{printf "%s ", $2} {print $1}' |
    xargs -r man
}

cht() {
  local q="$*"
  curl -s https://cht.sh/:list |
    fzf --query="$q" \
      --select-1 --exit-0 \
      --preview 'curl -s https://cht.sh/{1}' \
      --bind 'enter:execute(curl -s https://cht.sh/{})+abort'
  local rc=$?
  ((rc == 130)) && rc=0
  return "$rc"
}

ssh() {
  if [[ -z "$TMUX" ]]; then
    command ssh "$@"
    return $?
  fi

  local ssh_target=""
  local arg expect_value=0
  local after_doubledash=0

  for arg in "$@"; do
    if ((after_doubledash)); then
      ssh_target="$arg"
      break
    fi

    if ((expect_value)); then
      expect_value=0
      continue
    fi

    case "$arg" in
    --)
      after_doubledash=1
      continue
      ;;
    -[bBcDeEFIiJLlmOopQRSwWw])
      expect_value=1
      ;;
    -b* | -c* | -D* | -E* | -e* | -F* | -I* | -i* | -J* | -L* | -l* | -m* | -O* | -o* | -p* | -Q* | -R* | -S* | -W* | -w*) ;;
    -*) ;;
    *)
      ssh_target="$arg"
      break
      ;;
    esac
  done

  if [[ -n "$TMUX" ]] && [[ -t 0 || -t 2 ]]; then
    if [[ -n "$ssh_target" ]]; then
      printf '\033]0;ssh:%s\007' "$ssh_target" >/dev/tty
    fi
  fi

  command ssh "$@"
  local rc=$?

  if [[ -n "$TMUX" ]] && [[ -t 0 || -t 2 ]]; then
    printf '\033]0;\007' >/dev/tty
  fi

  return $rc
}
