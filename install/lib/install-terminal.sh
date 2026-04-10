#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

ENV="${1:-}"

collect_pkg_entries repo "$ENV" PKGS

install_repo_packages "${PKGS[@]}"
