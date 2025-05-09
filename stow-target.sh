#!/usr/bin/env bash

DRY_RUN=false
TARGET_HOME="${HOME}"

# Parse flags
while getopts "d" opt; do
  case $opt in
    d) DRY_RUN=true ;;
    *) echo "Usage: $0 [-d] <stow_directory>"; exit 1 ;;
  esac
done

shift $((OPTIND - 1)) # shift off the options

# Now the first non-option argument is the stow directory
if [ -z "$1" ]; then
  echo "Error: Stow directory must be specified."
  echo "Usage: $0 [-d] <stow_directory>"
  exit 1
fi

STOW_DIR=$(realpath "$1")

echo "Stowing dotfiles from $STOW_DIR to $TARGET_HOME..."

# Loop over subdirectories and apply stow
for dir in "$STOW_DIR"/*; do
  [ -d "$dir" ] || continue
  basename=$(basename "$dir")
  if [ "$DRY_RUN" = true ]; then
    echo "Dry run: stow --dotfiles -d '$STOW_DIR' -t '$TARGET_HOME' '$basename'"
  else
    echo "Stowing '$basename'..."
    stow --dotfiles -d "$STOW_DIR" -t "$TARGET_HOME" "$basename"
    if [ $? -ne 0 ]; then
        echo "Error: stow failed for directory '$basename'.  Exiting." >&2
        exit 1
    fi
  fi
done

