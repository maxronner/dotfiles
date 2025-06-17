export LANG=en_US.UTF-8
export EDITOR='nvim'

export MANPATH="/usr/local/man:$MANPATH"
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

tty=$(tty)
export GPG_TTY=$tty
export GNUPGHOME="$HOME/.config/gnupg"

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01:locus=01:quote=01'

# Add user's local bin and appimages to PATH
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/appimages" ] ; then
    PATH="$HOME/appimages:$PATH"
fi
