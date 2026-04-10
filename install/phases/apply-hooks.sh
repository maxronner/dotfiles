#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

bash "${REPO_ROOT}/install/60-configure-sway-desktop.sh"
bash "${REPO_ROOT}/install/61-create-sway-config-dir.sh"
bash "${REPO_ROOT}/install/40-enable-systemd-services.sh"
bash "${REPO_ROOT}/install/41-setup-timesyncd.sh"
python3 "${REPO_ROOT}/local/thememanager/thememanager" set auto
