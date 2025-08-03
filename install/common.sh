#!/usr/bin/env bash

set -euo pipefail

PACKAGE_MANAGER=(sudo pacman -Syu --needed --noconfirm)
AUR_HELPER=(yay --needed --noconfirm --sudoflags "-S")
