#!/usr/bin/env bash
set -euo pipefail

PASSDIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

echo "Securing permissions on: $PASSDIR"
chown -R "$USER":"$USER" "$PASSDIR"

find "$PASSDIR" -type d -exec chmod 0700 {} +
find "$PASSDIR" -type f -exec chmod 0600 {} +

echo "Permissions secured (dirs: 0700, files: 0600)"

