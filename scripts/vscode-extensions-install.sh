#!/usr/bin/env bash
# vscode-extensions-install.sh — install VS Code extensions sequentially.
# Called by fresh.sh. Installing sequentially avoids the ENOTEMPTY race condition
# that occurs when VS Code's extension installer runs in parallel.
# Full-line and inline # comments in the list are ignored.
#
# Usage: bash scripts/vscode-extensions-install.sh <extensions-list-file>
set -euo pipefail

EXTENSIONS_FILE="${1:-}"

if [[ -z "$EXTENSIONS_FILE" ]]; then
  echo "Usage: bash vscode-extensions-install.sh <extensions-list-file>"
  exit 1
fi

if ! command -v code &>/dev/null; then
  echo "    VS Code not found — skipping extensions"
  exit 0
fi

while IFS= read -r ext || [[ -n "$ext" ]]; do
  ext="${ext%%\#*}"           # strip comments
  ext="${ext//[[:space:]]/}"  # trim whitespace
  [[ -z "$ext" ]] && continue

  if code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
    printf '    \033[0;32mok\033[0m  %s\n' "$ext"
  else
    code --install-extension "$ext" --force 2>&1 | tail -1
    printf '    \033[0;32mok\033[0m  %s installed\n' "$ext"
  fi
done < "$EXTENSIONS_FILE"
