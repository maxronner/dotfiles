#!/usr/bin/env bash
# Remove managed symlinks. Usage:
#   ./install/unlink.sh <profile>

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

DOTFILES_ROOT="$(cd -- "${DOTS_DIR}/.." && pwd)"

PROFILE="${1:-}"
[[ -n "$PROFILE" ]] || { error "Usage: ./install/unlink.sh <profile>"; exit 1; }

shopt -s nullglob

# Unstow dots apps
info "Unstowing dots app dotfiles..."
for dir in "$DOTS_DIR"/apps/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"
    [[ "$name" == "nvim" ]] && continue
    stow --dotfiles --no-folding --delete --ignore="$STOW_IGNORE" \
        -d "$DOTS_DIR/apps" -t "$HOME_DIR" "$name"
done

# Unstow sibling WM repos
for wm in hyprland sway; do
    wm_dir="${DOTFILES_ROOT}/${wm}"
    [[ -d "$wm_dir/apps" ]] || continue
    info "Unstowing ${wm} app dotfiles..."
    for dir in "$wm_dir"/apps/*/; do
        [[ -d "$dir" ]] || continue
        name="$(basename "$dir")"
        stow --dotfiles --no-folding --delete --ignore="$STOW_IGNORE" \
            -d "$wm_dir/apps" -t "$HOME_DIR" "$name"
    done
    # Unstow WM device overrides
    if [[ -n "$PROFILE" && -d "$wm_dir/devices/$PROFILE" ]]; then
        info "Unstowing ${wm} ${PROFILE} device overrides..."
        stow --dotfiles --no-folding --delete --ignore="$STOW_IGNORE" \
            -d "$wm_dir/devices" -t "$HOME_DIR" "$PROFILE"
    fi
done

# Unstow dots device overrides
if [[ -n "$PROFILE" ]]; then
    info "Unstowing dots ${PROFILE} device overrides..."
    stow --dotfiles --no-folding --delete --ignore="$STOW_IGNORE" \
        -d "$DOTS_DIR/devices" -t "$HOME_DIR" "$PROFILE"
fi

# Remove local symlinks
info "Removing local symlinks..."
for f in "${DOTS_DIR}/local/dot-local/bin"/*; do
    [[ -f "$f" ]] || continue
    target="${HOME_DIR}/.local/bin/$(basename "$f")"
    [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$f" ]] && rm -f "$target"
done

for f in "${DOTS_DIR}/local/dot-local/lib"/*; do
    [[ -e "$f" ]] || continue
    target="${HOME_DIR}/.local/lib/$(basename "$f")"
    [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$f" ]] && rm -f "$target"
done

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

success "Unlink complete."
