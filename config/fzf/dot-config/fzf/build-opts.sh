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
    # shellcheck disable=SC1090
    source "$FZF_CONFIG_DIR/profile.sh"
  fi

  local fzf_color_opts="${FZF_COLOR_OPTS:-}"
  if [ -z "$fzf_color_opts" ]; then
    fzf_color_opts="--color=fg:#908caa,bg:#232136,hl:#ea9a97
      --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
      --color=border:#44415a,header:#3e8fb0,gutter:#232136
      --color=spinner:#f6c177,info:#9ccfd8
      --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
  fi
  fzf_color_opts=$(printf '%s' "$fzf_color_opts" | tr '\n' ' ')

  # --- Key Bindings ---
  local fzf_binds=(
    "ctrl-y:execute-silent(printf \"%s\" {} | wl-copy --trim-newline)"
    "ctrl-d:preview-half-page-down"
    "ctrl-u:preview-half-page-up"
    "ctrl-b:preview-page-up"
    "ctrl-f:preview-page-down"
    "ctrl-a:preview-top"
    "ctrl-e:preview-bottom"
    "ctrl-k:up"
    "ctrl-j:down"
  )

  local fzf_bind_opts=""
  local fzf_binds_joined=""
  fzf_binds_joined="$(IFS=,; printf '%s' "${fzf_binds[*]}")"
  fzf_bind_opts="--bind='$fzf_binds_joined'"

  # Combine into the final default variable
  local fzf_header_opts=""
  if [ -n "${FZF_HEADER_DEFAULT:-}" ]; then
    fzf_header_opts="--header='$FZF_HEADER_DEFAULT'"
  fi

  local fzf_default_opts=()
  # shellcheck disable=SC2206
  fzf_default_opts+=($fzf_color_opts)
  fzf_default_opts+=("$fzf_bind_opts")
  if [ -n "$fzf_header_opts" ]; then
    fzf_default_opts+=("$fzf_header_opts")
  fi

  local out=""
  local opt=""
  for opt in "${fzf_default_opts[@]}"; do
    [ -n "$opt" ] || continue
    if [ -n "$out" ]; then
      out+=" "
    fi
    out+="$opt"
  done

  printf '%s\n' "$out"
}

# 3. Execute Logic
_build_fzf_env

# 4. Cleanup
# Unset the function so it doesn't linger in your environment
unset -f _build_fzf_env
