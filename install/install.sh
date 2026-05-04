#!/usr/bin/env bash
# Dots repo installer. Handles shared infrastructure only.
# WM-specific configs are installed by their own repos.
#
# Usage:
#   ./install/install.sh [system|user|all] <profile>

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/packages.sh"

DOTFILES_ROOT="$DOTS_DIR"

phase="${1:-all}"
PROFILE="${2:-}"

if [[ -z "$PROFILE" ]]; then
    error "Usage: ./install/install.sh [system|user|all] <profile>"
    error "Available profiles:"
    for d in "${DOTS_DIR}/devices"/*/; do
        [[ -d "$d" ]] && echo "  - $(basename "$d")"
    done
    exit 1
fi

resolve_profile "$PROFILE" "$DOTS_DIR" >/dev/null || exit 1

# ── Package roots (internal) ────────────────────────────────────────────────

collect_install_package_paths() {
    local -n package_paths_ref="$1"
    local -a search_dirs=("${DOTS_DIR}/apps" "${DOTS_DIR}/system")
    [[ -n "$PROFILE" ]] && search_dirs+=("${DOTS_DIR}/devices/${PROFILE}")

    # Collect top-level pkg.txt from sibling WM repos (not via find — avoids double-counting)
    local -a extra_pkg_files=()
    for wm in hyprland sway; do
        local wm_dir="${DOTFILES_ROOT}/${wm}"
        [[ -d "$wm_dir" ]] || continue
        [[ -d "$wm_dir/apps" ]] && search_dirs+=("$wm_dir/apps")
        [[ -f "$wm_dir/pkg.txt" ]] && extra_pkg_files+=("$wm_dir/pkg.txt")
        if [[ -n "$PROFILE" && -d "$wm_dir/devices/$PROFILE" ]]; then
            search_dirs+=("$wm_dir/devices/$PROFILE")
        fi
    done

    package_paths_ref=("${extra_pkg_files[@]}" "${search_dirs[@]}")
}

# ── Stow local (internal) ──────────────────────────────────────────────────

stow_local() {
    shopt -s nullglob

    info "Symlinking local scripts..."
    mkdir -p "${HOME_DIR}/.local/bin" "${HOME_DIR}/.local/lib" "${HOME_DIR}/.local/share/themes"

    for f in "${DOTS_DIR}/local/dot-local/bin"/*; do
        [[ -f "$f" ]] && ln -sf "$f" "${HOME_DIR}/.local/bin/"
    done

    for f in "${DOTS_DIR}/local/dot-local/lib"/*; do
        if [[ -f "$f" ]]; then
            ln -sf "$f" "${HOME_DIR}/.local/lib/"
        elif [[ -d "$f" ]]; then
            ln -sfn "$f" "${HOME_DIR}/.local/lib/$(basename "$f")"
        fi
    done

    local link_target
    for f in "${HOME_DIR}/.local/share/themes"/*.txt; do
        if [[ ! -L "$f" ]]; then
            continue
        fi
        link_target="$(readlink "$f" 2>/dev/null || true)"
        if [[ "$link_target" == "${DOTS_DIR}/local/thememanager/color256/themes/"* ]]; then
            rm -f "$f"
        fi
    done

    shopt -u nullglob
}

# ── System setup (internal) ─────────────────────────────────────────────────

setup_system_services() {
    local -a services=(
        systemd-resolved.service
        systemd-timesyncd.service
        systemd-tmpfiles-clean.timer
    )
    info "Enabling system services..."
    sudo systemctl enable --now "${services[@]}"
}

setup_timesyncd() {
    local timezone="${1:-Europe/Stockholm}"
    local ntp_servers="${2:-0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org}"

    info "Configuring timesyncd..."
    sudo mkdir -p /etc/systemd/timesyncd.conf.d
    printf '[Time]\nNTP=%s\n' "$ntp_servers" | sudo tee /etc/systemd/timesyncd.conf.d/local.conf >/dev/null
    sudo timedatectl set-ntp false
    sudo timedatectl set-ntp true
    sudo systemctl restart systemd-timesyncd
    sudo timedatectl set-timezone "$timezone"
}

setup_user_services() {
    # Only enable WM-agnostic services. WM-specific services (mako, waybar,
    # quickshell) are the responsibility of each WM repo's install.sh.
    local -a services=(syncthing.service)

    local -a valid_services=()
    for unit in "${services[@]}"; do
        if systemctl --user cat "$unit" &>/dev/null; then
            valid_services+=("$unit")
        else
            warn "Unit not found: ${unit} — skipping"
        fi
    done

    if (( ${#valid_services[@]} == 0 )); then
        warn "No valid user services found."
        return 0
    fi

    info "Enabling user services..."
    systemctl --user enable --now "${valid_services[@]}"
    success "User services enabled."
}

# ── Finalize (internal) ─────────────────────────────────────────────────────

ensure_tpm() {
    local tpm_dir="${HOME_DIR}/.config/tmux/plugins/tpm"
    [[ -d "$tpm_dir" ]] && return 0
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

finalize() {
    ensure_tpm

    info "Setting up vim spell symlinks..."
    mkdir -p "${HOME_DIR}/.local/share/nvim/site/spell"
    stow -d /usr/share/vim/vimfiles -t "${HOME_DIR}/.local/share/nvim/site/spell" spell 2>/dev/null || true

    mkdir -p "${HOME_DIR}/.local/share/zsh"

    local theme_dir="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
    local palette_seed="${XDG_CONFIG_HOME:-$HOME/.config}/thememanager/palette.seed.json"
    mkdir -p "$theme_dir"
    if [[ ! -f "$theme_dir/palette.json" ]] && [[ -f "$palette_seed" ]]; then
        cp "$palette_seed" "$theme_dir/palette.json"
    fi

    theme-apply-all 2>/dev/null || true
}

# ── Phases ──────────────────────────────────────────────────────────────────

run_system() {
    info "=== System phase (dots) ==="

    local -a package_paths=()
    collect_install_package_paths package_paths
    validate_package_manifests "${package_paths[@]}"

    local -a REPO_PKGS=()
    collect_packages repo REPO_PKGS "${package_paths[@]}"
    install_repo_packages "${REPO_PKGS[@]}"

    local -a AUR_PKGS=()
    collect_packages aur AUR_PKGS "${package_paths[@]}"
    if (( ${#AUR_PKGS[@]} > 0 )); then
        ensure_yay
    fi
    install_aur_packages "${AUR_PKGS[@]}"

    setup_system_services
    setup_timesyncd

    run_device_setup "$PROFILE" "$DOTS_DIR"

    success "System phase complete."
}

run_user() {
    info "=== User phase (dots) ==="

    info "Stowing app dotfiles..."
    stow_all_apps "$DOTS_DIR"
    stow_device "$PROFILE" "$DOTS_DIR"
    stow_local
    finalize
    setup_user_services

    success "User phase complete."
}

# ── Dispatch ────────────────────────────────────────────────────────────────

case "$phase" in
    system) run_system ;;
    user)   run_user ;;
    all)    run_system; run_user ;;
    *)      error "Unknown phase: ${phase}"; exit 1 ;;
esac
