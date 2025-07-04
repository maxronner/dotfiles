# Disables XON/XOFF flow control, freeing up Ctrl+S and Ctrl+Q for use
stty -ixon

setopt globdots

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
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh
[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] && \
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
