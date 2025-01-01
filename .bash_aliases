# --- eza ---
if command -v eza &>/dev/null; then
    alias ls="eza --long --no-permissions --no-user --no-time --no-filesize --icons=always"
    alias ll="eza --long --all --git --group --icons=always"
fi

# --- thefuck ---
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# --- xclip ---
alias 2cb="xclip -selection clipboard"

# -- Debian specific ---
alias update-all="sudo apt update -y ; sudo apt dist-upgrade -y ; sudo apt autoremove -y ; sudo apt autoclean -y ; flatpak update -y"
alias update-all="sudo nala upgrade -y ; sudo nala autoremove -y ; flatpak update -y"
alias nala="sudo nala"

# Search command line history
alias h="history | grep "

# cd into the old directory
alias bd='cd "$OLDPWD"'

# cd backwards
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias vim-help="curl cheat.sh/vim"
alias reboot="systemctl reboot"

# --- PulseAudio
alias pa-dp="pactl set-default-sink alsa_output.hw_1_7"
alias pa-hp="pactl set-default-sink alsa_output.pci-0000_0d_00.4.analog-stereo"

alias gs="git status"
alias gc="git commit"
alias gd="git diff"
