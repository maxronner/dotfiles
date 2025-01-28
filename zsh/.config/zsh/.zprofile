# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    export GTK_THEME=Adwaita:dark
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    exec sway --unsupported-gpu
fi
