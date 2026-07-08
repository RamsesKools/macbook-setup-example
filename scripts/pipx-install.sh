#!/usr/bin/env bash
# pipx-install.sh — install pipx tools from a list file.
# Full-line and inline # comments in the list are ignored.
#
# Usage: bash scripts/pipx-install.sh <list-file>
set -euo pipefail

LIST_FILE="${1:-}"

if [[ -z "$LIST_FILE" ]]; then
  echo "Usage: bash scripts/pipx-install.sh <list-file>"
  exit 1
fi

while IFS= read -r pkg || [[ -n "$pkg" ]]; do
  pkg="${pkg%%\#*}"           # strip comments
  pkg="${pkg//[[:space:]]/}"  # trim whitespace
  [[ -z "$pkg" ]] && continue
  if pipx list | grep -q "$pkg"; then
    printf '    \033[0;32mok\033[0m  %s already installed\n' "$pkg"
  else
    pipx install "$pkg"
    printf '    \033[0;32mok\033[0m  %s installed\n' "$pkg"
  fi
done < "$LIST_FILE"
