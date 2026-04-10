#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/preflight.sh"
bash "${SCRIPT_DIR}/packages.sh" "${1:-}"
bash "${SCRIPT_DIR}/packages-aur.sh" "${1:-}"
bash "${SCRIPT_DIR}/activate.sh" "${1:-}"
