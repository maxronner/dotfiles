#!/usr/bin/env bash

set -euo pipefail

PACKAGE_MANAGER=(sudo pacman -Syu --needed --noconfirm)
AUR_HELPER=(yay -Syu --needed --noconfirm)

info() {
    printf "\033[1;34m[INFO]\033[0m %s\n" "$@"
}

success() {
    printf "\033[1;32m[SUCCESS]\033[0m %s\n" "$@"
}

warn() {
    printf "\033[1;33m[WARN]\033[0m %s\n" "$@"
}

error() {
    printf "\033[1;31m[ERROR]\033[0m %s\n" "$@" >&2
}
