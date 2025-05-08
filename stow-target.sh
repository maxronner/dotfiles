#!/usr/bin/env bash

STOW_DIR=""
TARGET_HOME="${HOME}"
USERNAME="${USERNAME:-$(whoami)}"
DRY_RUN=false

# Parse command line arguments
while getopts "d" opt; do
  case $opt in
    d) DRY_RUN=true ;;
    *) echo "Usage: $0 [-d for dry-run]"; exit 1 ;;
  esac
done

# Ensure STOW_DIR is provided
if [ -z "$1" ]; then
  echo "Error: Stow directory must be specified."
  echo "Usage: $0 <stow_directory> [-d for dry-run]"
  exit 1
fi

STOW_DIR=$(realpath "$1")

echo "Stowing dotfiles from $STOW_DIR to $TARGET_HOME..."

# Build the stow command with dry-run if needed
for dir in "$STOW_DIR"/*; do
  if [ -d "$dir" ]; then
    basename=$(basename "$dir")
    if [ "$DRY_RUN" = true ]; then
      echo "Dry run: stow --dotfiles -d '$STOW_DIR' -t '$TARGET_HOME' '$basename'"
    else
      stow --dotfiles -d "$STOW_DIR" -t "$TARGET_HOME" "$basename"
    fi
  fi
done

