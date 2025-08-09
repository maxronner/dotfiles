export MANPATH="/usr/local/man:$MANPATH"
export MANPAGER='nvim +Man!'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01:locus=01:quote=01'

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
tty=$(tty 2>/dev/null) && export GPG_TTY=$tty

[ -f "$XDG_CONFIG_HOME/environment/aliases.sh" ] && \
    source "$XDG_CONFIG_HOME/environment/aliases.sh"

[ -f "$XDG_CONFIG_HOME/environment/shell-functions.sh" ] && \
    source "$XDG_CONFIG_HOME/environment/shell-functions.sh"

# Note: Any FZF options set in this file will override those in app-configs.sh.
if command -v fzf &>/dev/null && [ -f "$XDG_CONFIG_HOME/fzf/config" ]; then
    source "$XDG_CONFIG_HOME/fzf/config"
fi
