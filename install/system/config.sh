#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Enable system-level systemd services
bash "${SCRIPT_DIR}/../lib/enable-system-services.sh"

# Configure NTP and timezone
bash "${SCRIPT_DIR}/../lib/setup-timesyncd.sh"

# Configure sway desktop entry (XDG, nvidia detection)
bash "${SCRIPT_DIR}/../lib/configure-sway-desktop.sh"
