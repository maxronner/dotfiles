#!/usr/bin/env bash

# 1. Setup Configuration Directory
# Fallback to ~/.config/fzf if XDG_CONFIG_HOME is not set
FZF_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fzf"

# 2. Define Function to Build Options
# Wrapping this in a function prevents 'fzf_binds' and modified 'IFS'
# from leaking into the global shell scope.
_build_fzf_env() {
  # --- Colors ---
  # If profile exists, source it, otherwise use default (Rose Pine)
  if [ -f "$FZF_CONFIG_DIR/profile.sh" ]; then
    source "$FZF_CONFIG_DIR/profile.sh"
  else
    export FZF_COLOR_OPTS="
      --color=fg:#908caa,bg:#232136,hl:#ea9a97
      --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
      --color=border:#44415a,header:#3e8fb0,gutter:#232136
      --color=spinner:#f6c177,info:#9ccfd8
      --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
  fi

  # --- Key Bindings ---
  local fzf_binds=(
    "ctrl-y:execute-silent(printf '%s' {} | wl-copy --trim-newline)"
    "ctrl-d:preview-half-page-down"
    "ctrl-u:preview-half-page-up"
    "ctrl-b:preview-page-up"
    "ctrl-f:preview-page-down"
    "ctrl-a:preview-top"
    "ctrl-e:preview-bottom"
    "ctrl-k:up"
    "ctrl-j:down"
  )

  # Join array with commas efficiently
  local IFS=,
  export FZF_BIND_OPTS="--bind='${fzf_binds[*]}'"

  # --- Headers & Assembly ---
  export FZF_HEADER_DEFAULT="(Ctrl+) J/K up/down · Y copy"

  # Combine into the final default variable
  FZF_DEFAULT_OPTS="
    $FZF_COLOR_OPTS
    $FZF_BIND_OPTS
    --header='$FZF_HEADER_DEFAULT'
  "

  printf '%s\n' "$FZF_DEFAULT_OPTS"
}

# 3. Execute Logic
_build_fzf_env

# 4. Cleanup
# Unset the function so it doesn't linger in your environment
unset -f _build_fzf_env
