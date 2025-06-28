[ -f "$XDG_CONFIG_HOME/environment/app-configs.sh" ] && \
    source "$XDG_CONFIG_HOME/environment/app-configs.sh"

[ -f "$XDG_CONFIG_HOME/environment/device-exports.sh" ] && \
    source "$XDG_CONFIG_HOME/environment/device-exports.sh"

[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
