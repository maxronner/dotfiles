#!/usr/bin/env bash
# scope: user
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

bash "${SCRIPT_DIR}/../lib/init-nvim.sh"
