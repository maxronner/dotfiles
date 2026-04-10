#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/common.sh"

info "Applying workstation NVIDIA SwayFX configuration…"

WRAPPER="/usr/local/bin/swayfx-nvidia-start"
DESKTOP_FILE="/usr/share/wayland-sessions/swayfx-nvidia.desktop"

# ---------------------------------------------------------------------------
# Wrapper: NVIDIA-safe environment for wlroots
# ---------------------------------------------------------------------------

sudo install -Dm755 /dev/stdin "$WRAPPER" << 'EOF'
#!/bin/sh

export WLR_DRM_NO_MODIFIERS=1
export WLR_DRM_NO_DIRECT_SCANOUT=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia

exec sway --unsupported-gpu
EOF

info "Installed SwayFX NVIDIA wrapper at: $WRAPPER"

# ---------------------------------------------------------------------------
# Session entry for ly
# ---------------------------------------------------------------------------

sudo install -Dm644 /dev/stdin "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Name=SwayFX (NVIDIA)
Comment=SwayFX with NVIDIA GBM-safe environment
Exec=/usr/local/bin/swayfx-nvidia-start
Type=Application
EOF

info "Registered NVIDIA SwayFX session: $DESKTOP_FILE"

success "NVIDIA SwayFX workstation configuration complete."

