[ -f "$XDG_CONFIG_HOME/shell/app-configs.sh" ] && \
    source "$XDG_CONFIG_HOME/shell/app-configs.sh"

[ -f "$XDG_CONFIG_HOME/shell/device-exports.sh" ] && \
    source "$XDG_CONFIG_HOME/shell/device-exports.sh"

# Add ~/.local/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
