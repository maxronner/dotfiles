#!/usr/bin/env bash
# Shared contract for dotfiles multi-repo architecture.
# WM repos source this file and call these functions.
# Do not add functions without updating ADR-001.

set -euo pipefail

readonly DOTS_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTS_DIR="$(cd -- "${DOTS_LIB_DIR}/.." && pwd)"
readonly HOME_DIR="${HOME:-/home/$(whoami)}"
readonly STOW_IGNORE='^(pkg\.txt|group\.txt|\.gitignore)$'

# ── Logging ──────────────────────────────────────────────────────────────────

info()    { printf "\033[1;34m[INFO]\033[0m %s\n" "$@"; }
success() { printf "\033[1;32m[SUCCESS]\033[0m %s\n" "$@"; }
warn()    { printf "\033[1;33m[WARN]\033[0m %s\n" "$@"; }
error()   { printf "\033[1;31m[ERROR]\033[0m %s\n" "$@" >&2; }

# ── 1. resolve_profile ───────────────────────────────────────────────────────
# Validates that a device profile directory exists in a given repo.
# Args: $1 = profile name (e.g. "laptop"), $2 = repo root
# Prints the device dir path, or returns 1.
resolve_profile() {
    local profile="${1:?Usage: resolve_profile <device> <repo_root>}"
    local repo_root="${2:?}"
    local dir="$repo_root/devices/$profile"
    [[ -d "$dir" ]] || { warn "No device profile '$profile' in $repo_root"; return 1; }
    echo "$dir"
}

# ── 2. stow_app ─────────────────────────────────────────────────────────────
# Stows a single app directory into $HOME.
# Uses --dotfiles (dot-config → .config) and --no-folding (individual file
# symlinks, not directory symlinks).
# Args: $1 = app directory (e.g. ~/dotfiles/dots/apps/zsh)
stow_app() {
    local app_dir="${1:?}"
    local name
    name="$(basename "$app_dir")"
    stow --dotfiles --no-folding --restow --ignore="$STOW_IGNORE" \
        -d "$(dirname "$app_dir")" -t "$HOME_DIR" "$name"
}

# ── 3. stow_all_apps ────────────────────────────────────────────────────────
# Stows every app in a repo's apps/ directory.
# Args: $1 = repo root
stow_all_apps() {
    local repo_root="${1:?}"
    for app in "$repo_root"/apps/*/; do
        [[ -d "$app" ]] || continue
        local name
        name="$(basename "$app")"
        [[ "$name" == "nvim" ]] && continue
        info "  ${name}"
        stow_app "$app"
    done
}

# ── 4. stow_device ──────────────────────────────────────────────────────────
# Stows device-specific configs (dot-config, dot-local dirs).
# Args: $1 = profile name, $2 = repo root
stow_device() {
    local device_dir
    device_dir="$(resolve_profile "$1" "$2")" || return 1
    stow_app "$device_dir"
}

# ── 5. run_device_setup ─────────────────────────────────────────────────────
# Runs imperative setup for a device profile:
#   - Copies etc/ to /etc (sudo)
#   - Sources specifics/setup-<profile>.sh if present
# Args: $1 = profile name, $2 = repo root
run_device_setup() {
    local profile="${1:?}"
    local repo_root="${2:?}"
    local device_dir="$repo_root/devices/$profile"

    if [[ -d "$device_dir/etc" ]]; then
        info "Installing system configs from ${device_dir}/etc/..."
        sudo cp -r "$device_dir/etc/"* /etc/
    fi

    local setup="$repo_root/install/specifics/setup-${profile}.sh"
    if [[ -f "$setup" ]]; then
        info "Running ${profile} device setup..."
        bash "$setup"
    fi
}

# ── 6. ensure_deps ──────────────────────────────────────────────────────────
# Checks that commands are available on PATH.
# Args: list of command names
ensure_deps() {
    local missing=()
    for cmd in "$@"; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing commands: ${missing[*]}"
        return 1
    fi
}
