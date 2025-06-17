if [ -f "$HOME/.config/environment/app-configs.sh" ]; then
    source "$HOME/.config/environment/app-configs.sh"
fi

if [ -f "$HOME/.config/environment/device-exports.sh" ]; then
    source "$HOME/.config/environment/device-exports.sh"
fi
