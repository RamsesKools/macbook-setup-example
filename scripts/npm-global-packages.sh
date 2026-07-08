#!/usr/bin/env bash
# npm-global-packages.sh — install npm global packages from a list file.
# Full-line and inline # comments in the list are ignored.
#
# Usage: bash scripts/npm-global-packages.sh <list-file>
set -euo pipefail

LIST_FILE="${1:-}"

if [[ -z "$LIST_FILE" ]]; then
  echo "Usage: bash scripts/npm-global-packages.sh <list-file>"
  exit 1
fi

while IFS= read -r pkg || [[ -n "$pkg" ]]; do
  pkg="${pkg%%\#*}"           # strip comments
  pkg="${pkg//[[:space:]]/}"  # trim whitespace
  [[ -z "$pkg" ]] && continue
  npm install -g "$pkg"
  printf '    \033[0;32mok\033[0m  %s\n' "$pkg"
done < "$LIST_FILE"
