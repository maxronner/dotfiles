# This file is sourced by ~/.zshrc

export GTK_THEME=Adwaita:dark

# Source FZF's user configuration file if it exists.
# Note: Any FZF options set in this file will override those in app-configs.sh.
if command -v fzf &>/dev/null && [ -f "$XDG_CONFIG_HOME/fzf/config" ]; then
    source "$XDG_CONFIG_HOME/fzf/config"
fi
