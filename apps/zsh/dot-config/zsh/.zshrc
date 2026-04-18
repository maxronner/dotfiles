# Disables XON/XOFF flow control, freeing up Ctrl+S and Ctrl+Q for use
stty -ixon

WORDCHARS=${WORDCHARS/\/}
fpath=($XDG_CONFIG_HOME/zsh/completions $fpath)

setopt globdots
setopt HIST_IGNORE_SPACE
setopt INTERACTIVE_COMMENTS

bindkey -v
bindkey '\e[3~' delete-char # Mapping <Del> to delete
bindkey '^B' backward-word
bindkey '^[.' insert-last-word
bindkey '^[+' copy-prev-shell-word

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line

# Source interactive shell configs
[ -f "$XDG_CONFIG_HOME/shell/interactive-shell-configs.sh" ] && \
    source "$XDG_CONFIG_HOME/shell/interactive-shell-configs.sh"

if [ -d "$XDG_CONFIG_HOME/zsh/plugins" ]; then
    for plugin in "$XDG_CONFIG_HOME/zsh/plugins"/*.zsh; do
        source "$plugin"
    done
fi

[ -f "$XDG_CONFIG_HOME/zsh/completion.zsh" ] && \
    source "$XDG_CONFIG_HOME/zsh/completion.zsh"

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

    zle-autosuggest-accept-or-end() {
        zle autosuggest-accept
        zle end-of-line
    }
    zle -N zle-autosuggest-accept-or-end
    bindkey '^E' zle-autosuggest-accept-or-end
fi
[ -f /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-completions/zsh-completions.zsh
[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] && \
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

if [[ -n ${NOHIST-} ]]; then
    [[ -o interactive ]] && print -P '%F{yellow}%B shell history is disabled (NOHIST is set) %b%f'
    setopt histnostore
    unsetopt sharehistory incappendhistory incappendhistorytime appendhistory
    unset HISTFILE
    export HISTFILE=/dev/null
fi

# External tools
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
