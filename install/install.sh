#!/usr/bin/env bash
# Dots repo installer. Handles shared infrastructure only.
# WM-specific configs are installed by their own repos.
#
# Usage:
#   ./install/install.sh [system|user|all] <profile>

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

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

# ── Package management (internal) ───────────────────────────────────────────

readonly PACKAGE_MANAGER=(sudo pacman -Syu --needed --noconfirm)
readonly AUR_HELPER=(yay -Syu --needed --noconfirm)

ensure_yay() {
    command -v yay &>/dev/null && return 0
    local tmp_dir="${HOME}/yay"
    info "yay not found. Installing..."
    trap 'rm -rf "$tmp_dir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$tmp_dir"
    (cd "$tmp_dir" && makepkg -si --noconfirm)
}

collect_pkg_entries() {
    local package_type="$1"
    local -n packages_ref="$2"

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

    local -a pkg_files=("${extra_pkg_files[@]}")
    local -a packages=()

    local pkg_file line
    while IFS= read -r pkg_file; do
        pkg_files+=("$pkg_file")
    done < <(find "${search_dirs[@]}" -name "pkg.txt" -print 2>/dev/null)

    for pkg_file in "${pkg_files[@]}"; do
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="${line%%#*}"
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"
            [[ -z "$line" ]] && continue

            case "$package_type" in
                repo) [[ "$line" == aur:* ]] && continue; packages+=("$line") ;;
                aur)  [[ "$line" == aur:* ]] || continue; packages+=("${line#aur:}") ;;
                *)    error "Unknown package type: $package_type"; return 1 ;;
            esac
        done < "$pkg_file"
    done

    if (( ${#packages[@]} == 0 )); then
        packages_ref=()
        return 0
    fi
    mapfile -t packages_ref < <(printf '%s\n' "${packages[@]}" | sort -u)
}

install_repo_packages() {
    local -a pkgs=("$@")
    (( ${#pkgs[@]} == 0 )) && return 0
    info "Installing ${#pkgs[@]} packages..."
    "${PACKAGE_MANAGER[@]}" "${pkgs[@]}"
}

install_aur_packages() {
    local -a pkgs=("$@")
    (( ${#pkgs[@]} == 0 )) && return 0
    info "Installing ${#pkgs[@]} AUR packages..."
    "${AUR_HELPER[@]}" "${pkgs[@]}"
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

    for f in "${HOME_DIR}/.local/share/themes"/*.txt; do
        if [[ -L "$f" ]] && [[ "$(readlink -f "$f")" == "${DOTS_DIR}/local/thememanager/color256/themes/"* ]]; then
            rm -f "$f"
        fi
    done
    for f in "${DOTS_DIR}/local/thememanager/color256/themes"/*.txt; do
        [[ -f "$f" ]] && ln -sf "$f" "${HOME_DIR}/.local/share/themes/"
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

    ensure_yay

    local -a REPO_PKGS=()
    collect_pkg_entries repo REPO_PKGS
    install_repo_packages "${REPO_PKGS[@]}"

    local -a AUR_PKGS=()
    collect_pkg_entries aur AUR_PKGS
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
