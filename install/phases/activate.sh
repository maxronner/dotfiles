#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/device.sh" "${1:-}"
bash "${SCRIPT_DIR}/apply-home.sh" "${1:-}"
bash "${SCRIPT_DIR}/apply-hooks.sh"
