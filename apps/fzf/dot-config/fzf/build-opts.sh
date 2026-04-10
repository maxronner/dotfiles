#!/usr/bin/env bash

# 1. Setup Configuration Directory
# Fallback to ~/.config/fzf if XDG_CONFIG_HOME is not set
FZF_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fzf"

# 2. Define Function to Build Options
# Wrapping this in a function prevents 'fzf_binds' and modified 'IFS'
# from leaking into the global shell scope.
_build_fzf_env() {
  # --- Colors ---
  # Source profile if it exists (sets FZF_COLOR_OPTS using terminal palette indices)
  if [ -f "$FZF_CONFIG_DIR/profile.sh" ]; then
    # shellcheck disable=SC1090
    source "$FZF_CONFIG_DIR/profile.sh"
  fi

  # Allow caller to force 256-color mode (e.g. Neovim with termguicolors=false)
  local fzf_color_opts="${FZF_COLOR_OPTS:-}"

  if [ -z "$fzf_color_opts" ]; then
    # Fallback: Rose Pine palette indices
    fzf_color_opts="--color=fg:7,bg:0,hl:4
      --color=fg+:7,bg+:8,hl+:4
      --color=border:8,header:4,gutter:0,separator:-1
      --color=spinner:3,info:6
      --color=pointer:5,marker:1,prompt:7
      --color=bg:-1,bg+:-1"
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
  fzf_binds_joined="$(
    IFS=,
    printf '%s' "${fzf_binds[*]}"
  )"
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
_build_fzf_env "$@"

# 4. Cleanup
# Unset the function so it doesn't linger in your environment
unset -f _build_fzf_env
