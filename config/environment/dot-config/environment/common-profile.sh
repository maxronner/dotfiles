export LANG=en_US.UTF-8
export EDITOR='nvim'

export MANPATH="/usr/local/man:$MANPATH"
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

export GPG_TTY=$(tty)

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# GTK2
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

export FZF_DEFAULT_OPTS="
    --color=fg:#908caa,bg:#232136,hl:#ea9a97
    --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
    --color=border:#44415a,header:#3e8fb0,gutter:#232136
    --color=spinner:#f6c177,info:#9ccfd8
    --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa
    --bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | wl-copy --trim-newline)'"

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/appimages" ] ; then
    PATH="$HOME/appimages:$PATH"
fi

if [ -z "$WAYLAND_DISPLAY" ] ; then
    export GTK_THEME=Adwaita:dark
    export ELECTRON_OZONE_PLATFORM_HINT=auto
fi
