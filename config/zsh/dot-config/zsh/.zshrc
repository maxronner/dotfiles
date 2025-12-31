# Disables XON/XOFF flow control, freeing up Ctrl+S and Ctrl+Q for use
stty -ixon

WORDCHARS=${WORDCHARS/\/}

setopt globdots

bindkey -e # Use emacs key bindings
bindkey '\e[3~' delete-char # Mapping <Del> to delete
bindkey '^B' backward-word
bindkey '^[.' insert-last-word
bindkey '^S' end-of-line
bindkey '^E' vi-forward-blank-word-end

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line

# External tools
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Source interactive shell configs
[ -f "$XDG_CONFIG_HOME/environment/interactive-shell-configs.sh" ] && \
    source "$XDG_CONFIG_HOME/environment/interactive-shell-configs.sh"

# Source plugins
[ -d "$XDG_CONFIG_HOME/zsh/plugins" ] && \
    for plugin in "$XDG_CONFIG_HOME/zsh/plugins"/*.zsh; do
        source "$plugin"
    done

# Alias finder settings
zstyle ':custom:plugins:alias-finder' autoload yes
zstyle ':custom:plugins:alias-finder' cheaper yes

# Extras
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    zle-autosuggest-accept-partial-and-forward-word() {
        zle forward-word
    }
    zle -N zle-autosuggest-accept-partial-and-forward-word
    bindkey '^F' zle-autosuggest-accept-partial-and-forward-word
fi
[ -f /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh
[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] && \
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
