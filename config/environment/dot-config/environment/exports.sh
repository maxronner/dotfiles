if [ -f "$HOME/.config/environment/device-exports.sh" ]; then
    source "$HOME/.config/environment/device-exports.sh"
fi

if command -v pass &>/dev/null ; then
    export PASSWORD_STORE_ENABLE_EXTENSIONS=true
    export PASSWORD_STORE_DIR="$HOME/personal/.password-store"
fi

if command -v fzf &>/dev/null && [ -f "$HOME/.config/fzf/config" ]; then
    source "$HOME/.config/fzf/config"
fi

