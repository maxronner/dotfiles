#!/usr/bin/env bash
# scope: user
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

STOW_CONFIG_DIR="${REPO_ROOT}/apps"
STOW_DEVICES_DIR="${REPO_ROOT}/devices"
ENV="${1:-}"

echo "Unstowing system dotfiles from $HOME..."
for dir in "$STOW_CONFIG_DIR"/*; do
    if [ -d "$dir" ]; then
        name="$(basename "$dir")"
        [[ "$name" == "nvim" ]] && continue  # nvim is opt-in, skip unless explicitly unstowed
        echo "Unstowing ${name}..."
        stow --dotfiles --no-folding --delete --ignore='^(pkg\.txt|\.gitignore)$' -d "$STOW_CONFIG_DIR" -t "$HOME" "$name"
    fi
done

if [[ -n "$ENV" ]]; then
    echo "Unstowing $ENV specific dotfiles from devices..."
    stow --dotfiles --no-folding --delete --ignore='^(pkg\.txt|\.gitignore)$' -d "$STOW_DEVICES_DIR" -t "$HOME" "$ENV"
else
    echo "env is not set, skipping env-specific unstow."
fi

echo "Removing manually linked local scripts..."
for f in "$REPO_ROOT"/local/dot-local/bin/* "$REPO_ROOT"/scripts/dot-local/bin/*; do
    if [ -f "$f" ]; then
        target="$HOME/.local/bin/$(basename "$f")"
        if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$f" ]; then
            rm -f "$target"
        fi
    fi
done

echo "Removing manually linked theme assets..."
for f in "$HOME/.local/share/themes"/*.txt; do
    if [ -L "$f" ] && [ "$(readlink -f "$f")" != "$f" ] && [[ "$(readlink -f "$f")" == "$REPO_ROOT"/local/thememanager/color256/themes/* ]]; then
        rm -f "$f"
    fi
done
