#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/40-enable-system-services.sh"
bash "${SCRIPT_DIR}/41-enable-user-services.sh"
