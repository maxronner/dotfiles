export EDITOR='nvim'

export GTK_THEME=Adwaita:dark
export GTK_IM_MODULE=simple
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

export PASSWORD_STORE_ENABLE_EXTENSIONS=true
export PASSWORD_STORE_DIR="$HOME/personal/.password-store"

if [ -z "$WAYLAND_DISPLAY" ]; then
  export ELECTRON_OZONE_PLATFORM_HINT=auto
fi
