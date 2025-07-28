#!/usr/bin/env bash
# zk-sync.sh
# Triggered manually or as part of your `zk` wrapper
# It assumes editing is done

set -euo pipefail

ZK_NOTEBOOK_DIR="${ZK_NOTEBOOK_DIR:-$HOME/notebook}"
cd "$ZK_NOTEBOOK_DIR" || {
  echo "[zk-sync] Error: notebook directory not found: $ZK_NOTEBOOK_DIR"
  exit 1
}

git pull

echo "[zk-sync] Checking for changes in $ZK_NOTEBOOK_DIR..."

# Stage all modified/deleted/added files
git add .

# Check if there's anything to commit
if git diff --cached --quiet; then
  echo "[zk-sync] No changes to commit."
else
  # Optional: show what will be committed
  echo "[zk-sync] Changes to be committed:"
  git diff --cached --stat

  COMMIT_MSG="zk: auto commit $(date '+%F %T')"
  git commit -m "$COMMIT_MSG" || {
    echo "[zk-sync] Commit failed."
    exit 1
  }

  echo "[zk-sync] Committed: $COMMIT_MSG"

  # Try pushing and report any issues
  if git push; then
    echo "[zk-sync] Push successful."
  else
    echo >&2 "[zk-sync] ⚠️ Push failed! Resolve manually."
    exit 1
  fi
fi

