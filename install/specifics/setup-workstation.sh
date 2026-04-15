#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

# Packages now handled centrally via pkg.txt.
# If gamescope/gamemode/steam/swayfx are needed, add to devices/workstation/pkg.txt.
info "Workstation setup complete (packages handled via pkg.txt)."
