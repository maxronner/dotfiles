export EDITOR='nvim'

export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

export PASSWORD_STORE_ENABLE_EXTENSIONS=true
export PASSWORD_STORE_DIR="$HOME/personal/.password-store"

# FZF configuration options, needs to be sourced by ~/.zprofile for tmux
export FZF_COLOR_OPTS="
    --color=fg:#908caa,bg:#232136,hl:#ea9a97
    --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
    --color=border:#44415a,header:#3e8fb0,gutter:#232136
    --color=spinner:#f6c177,info:#9ccfd8
    --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
export FZF_BIND_OPTS="
    --bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | wl-copy --trim-newline),ctrl-d:preview-page-down,ctrl-u:preview-page-up,ctrl-y:preview-up,ctrl-e:preview-down,ctrl-b:preview-page-up,ctrl-f:preview-page-down,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,shift-up:preview-top,shift-down:preview-bottom,alt-up:half-page-up,alt-down:half-page-down'"
export FZF_DEFAULT_OPTS="$FZF_COLOR_OPTS $FZF_BIND_OPTS"
export FZF_TMUX_PANE_OPTS="bottom,40%,border-native"
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'

if [ -z "$WAYLAND_DISPLAY" ]; then
  export ELECTRON_OZONE_PLATFORM_HINT=auto
fi
