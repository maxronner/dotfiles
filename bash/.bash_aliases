if command -v eza &>/dev/null; then
    alias tree="eza --tree --level=3"
    alias ll="eza --long --all --git --group --icons=always"
    alias ls="eza --long --no-permissions --no-user --no-time --no-filesize --icons=always"
fi

if command -v nvim &>/dev/null; then
    alias vim="nvim"
fi

# --- thefuck ---
eval $(thefuck --alias)
eval $(thefuck --alias fk)

alias 2cb="xclip -selection clipboard"

# -- Debian specific ---
alias update-all="sudo apt update -y ; sudo apt dist-upgrade -y ; sudo apt autoremove -y ; sudo apt autoclean -y ; flatpak update -y"
alias update-all="sudo nala upgrade -y ; sudo nala autoremove -y ; flatpak update -y"
alias nala="sudo nala"

alias h="history | grep "
alias bd='cd "$OLDPWD"'

# cd backwards
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias reboot="systemctl reboot"

# --- Git ---
alias gs="git status"
alias gc="git commit"
alias gd="git diff"
alias gp="git push"
