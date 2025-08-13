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
fi

if command -v bat &>/dev/null; then
    alias cat="bat"
fi

alias pw="pass fzf"
alias otp="pass fzf-otp"
alias chat="tmux-chat"
alias cb="wl-copy"
alias bt="bluetui"
alias pm="pulsemixer"
alias zi="zoxide query --interactive"

# --- system ---
alias reboot="systemctl reboot"

# --- cd backwards ---
alias bd='cd "$OLDPWD"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# --- Git ---
alias g="git"

alias ga="git add"
alias gaa="git add --all"
alias gap="git add --patch"

alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'

alias gsw='git switch'

alias gc="git commit"
alias gca="git commit --amend"

alias gm='git merge'
alias gd='git diff'
alias gs="git status --short"
alias gp="git push"
alias gu="git pull"
alias gb="git branch"
alias gi="git init"
alias gcl="git clone"

alias glo='git log --oneline --decorate --graph --all'
alias glg='git log --graph --decorate --all'

alias gco='git checkout'
alias gcb='git checkout -b'
alias gcB='git checkout -B'

alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# --- Taskwarrior ---
alias t="task"
alias ts="task sync"
alias tt="taskwarrior-tui"
alias tan="task annotate"
alias ta="task add"
alias tdo="task done"
alias tde="task delete"
alias te="task edit"
alias tm="task modify"
