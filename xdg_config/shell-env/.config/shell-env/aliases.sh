if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if command -v eza &>/dev/null; then
    alias tree="eza --tree --level=3"
    alias ll="eza --long --all --icons --git --mounts --smart-group"
    alias ls="eza --no-permissions --no-user --no-time --no-filesize --icons=always"
fi

if command -v nvim &>/dev/null; then
    alias vim="nvim"
fi

if command -v pass &>/dev/null; then
    alias pw="pass fzf"
    alias otp="pass fzf-otp"
fi

if command -v gh &>/dev/null; then
    alias ai="gh copilot"
fi

if command -v gurk &>/dev/null && command -v tmux-sessionizer &>/dev/null ; then
    alias gurk="tmux-sessionizer gurk"
fi

# --- thefuck ---
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# --- system ---
alias h="history | grep "
alias bd='cd "$OLDPWD"'
alias reboot="systemctl reboot"

# --- cd backwards ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# --- Git ---
alias gs="git status"
alias gc="git commit"
alias gd="git diff"
alias gp="git push"

alias ssh-copy-id-clipboard="wl-copy 'echo \"$(cat ~/.ssh/id_ed25519.pub)\" >> ~/.ssh/authorized_keys'"
