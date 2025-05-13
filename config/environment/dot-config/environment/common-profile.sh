export LANG=en_US.UTF-8
export EDITOR='nvim'

export MANPATH="/usr/local/man:$MANPATH"
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# GTK2
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    export GTK_THEME=Adwaita:dark
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    exec sway --unsupported-gpu
fi
