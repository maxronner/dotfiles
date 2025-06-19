if [ -x /usr/bin/dircolors ]; then
    if test -r ~/.dircolors; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if command -v eza &>/dev/null; then
    alias lt="eza --tree --level=5"
    alias ll="eza --long --all --icons --git --mounts --smart-group"
    alias ls="eza --no-permissions --no-user --no-time --no-filesize --icons=always"
    alias l="eza --no-permissions --no-user --no-time --no-filesize --icons=always --long"
fi

if command -v nvim &>/dev/null; then
    alias vim="nvim"
    alias nano="nvim"
    alias svim="sudo nvim"
    alias v="nvim"
fi

if command -v bat &>/dev/null; then
    alias cat="bat"
fi


fat() {
  local result
  # Use --color=never to ensure wc -l counts actual lines, not ANSI escape codes
  result="$(fd --absolute-path --color=never "$@" .)"
  local line_count
  line_count=$(echo "$result" | wc -l)

  if [ -z "$result" ]; then
    echo "No files found."
  elif [ "$line_count" -gt 1 ]; then
    local selected_file
    selected_file=$(echo "$result" | fzf)
    if [ -n "$selected_file" ]; then
      cat "$selected_file"
    else
      echo "Selection cancelled."
    fi
  else # line_count is 1
    cat "$result"
  fi
}

alias pw="pass fzf"
alias otp="pass fzf-otp"
alias chat="tmux-chat"
alias cb="wl-copy"
alias bt="bluetui"
alias pm="pulsemixer"
alias zi="zoxide query --interactive"

# --- system ---
alias bd='cd "$OLDPWD"'
alias reboot="systemctl reboot"

# --- cd backwards ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# --- Git ---
alias gs="git status --short"
alias gc="git commit"
alias gd="git diff"
alias gp="git push"
alias gu="git pull"
alias gl="git log --pretty=format:'%C(yellow)%h%Creset %C(green)%<(12,trunc)%ar%Creset %C(red)•%Creset %s %C(bold blue)<%an>%Creset'"
alias gb="git branch"
alias gi="git init"
alias gcl="git clone"
alias gap="git add --patch"
alias glg="git log --graph --decorate"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gca="git commit --amend"

alias t="task"
alias tt="taskwarrior-tui"
alias tan="task annotate"
alias ta="task add"
alias tdo="task done"
alias tde="task delete"
alias te="task edit"
alias tm="task modify"
