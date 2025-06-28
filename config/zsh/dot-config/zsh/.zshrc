setopt globdots

# Enable vi-mode
bindkey -v

# External tools
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

[ -f "$XDG_CONFIG_HOME/environment/interactive-shell-configs.sh" ] && \
    source "$XDG_CONFIG_HOME/environment/interactive-shell-configs.sh"

[ -d "$XDG_CONFIG_HOME/zsh/plugins" ] && \
    for plugin in "$XDG_CONFIG_HOME/zsh/plugins"/*.zsh; do
        source "$plugin"
    done

zstyle ':custom:plugins:alias-finder' autoload yes
zstyle ':custom:plugins:alias-finder' cheaper yes

[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh
[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] && \
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
