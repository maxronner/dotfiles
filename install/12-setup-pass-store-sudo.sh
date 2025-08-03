#!/usr/bin/env bash
set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/secure-pass-store-unmount"
USER="$(id -un)"
MOUNT_POINT="/dev/shm/secure-pass-store"
UMOUNT_BIN="$(command -v umount)"
VISUDO_BIN="$(command -v visudo)"

if [[ "${1:-}" == "--remove" ]]; then
    echo "Removing sudoers rule at $SUDOERS_FILE"
    sudo rm -f "$SUDOERS_FILE"
    exit 0
fi

if [ -z "$UMOUNT_BIN" ]; then
    echo "Error: 'umount' command not found. Cannot create sudoers rule."
    exit 1
fi

if [ -z "$VISUDO_BIN" ]; then
    echo "Error: 'visudo' command not found. Cannot validate sudoers rule."
    exit 1
fi

RULE="$USER ALL=(root) NOPASSWD: $UMOUNT_BIN $MOUNT_POINT"

# If the rule already exists, do nothing.
if sudo grep -Fxq "$RULE" "$SUDOERS_FILE" 2>/dev/null; then
    echo "Sudoers rule for passwordless unmount is already present."
    exit 0
fi

echo "This script will add the following rule to sudoers to allow passwordless unmounting of the secure pass store:"
echo
echo "    $RULE"
echo
read -p "Do you want to proceed? [y/N] " -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted by user."
    exit 1
fi

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT # Ensure temp file is cleaned up

echo "$RULE" > "$TMP_FILE"

if ! sudo "$VISUDO_BIN" -c -f "$TMP_FILE"; then
    echo "Error: The generated sudoers rule has a syntax error. Aborting."
    exit 1
fi

echo "Adding sudoers rule to allow passwordless unmount of $MOUNT_POINT for user $USER"
sudo chown root:root "$TMP_FILE"
sudo chmod 440 "$TMP_FILE"
sudo mv "$TMP_FILE" "$SUDOERS_FILE"

echo "Sudoers rule successfully added and verified."
