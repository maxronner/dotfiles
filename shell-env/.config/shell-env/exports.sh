if [ -f ~/.config/shell-env/device-exports.sh ]; then
    source ~/.config/shell-env/device-exports.sh
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export ZK_NOTEBOOK_DIR="/home/max/Sync/Markdown"

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
fi

if command -v fzf &>/dev/null && [ -f ~/.config/fzf/config ]; then
    source ~/.config/fzf/config
fi

