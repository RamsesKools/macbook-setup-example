#!/usr/bin/env bash
# clone-workspace.sh — clone all repos for a single workspace from a list file.
# Called once per workspace by fresh.sh.
#
# Usage:
#   GitHub workspace (auth via gh):
#     bash scripts/clone-workspace.sh github <gh-username> <workspace-dir> <list-file>
#
#   Git-over-SSH workspace (any host without a CLI like gh, e.g. Azure DevOps;
#   uses plain git clone with an SSH key):
#     bash scripts/clone-workspace.sh ssh <workspace-dir> <list-file>
#
# GitHub list file format (one repo per line):
#   org/repo
#
# SSH list file format (one repo per line, tab or space separated):
#   <ssh-url>  <dest-folder-name>
#
# Full-line and inline # comments in the list files are ignored.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

PROVIDER="${1:-}"
if [[ "$PROVIDER" == "github" ]]; then
  GH_USER="$2"
  WORKSPACE_DIR="$3"
  LIST_FILE="$4"
elif [[ "$PROVIDER" == "ssh" ]]; then
  WORKSPACE_DIR="$2"
  LIST_FILE="$3"
else
  echo "Usage:"
  echo "  bash clone-workspace.sh github <gh-username> <workspace-dir> <list-file>"
  echo "  bash clone-workspace.sh ssh <workspace-dir> <list-file>"
  exit 1
fi

mkdir -p "$WORKSPACE_DIR"

# ── GitHub workspace ───────────────────────────────────────────────────────────

if [[ "$PROVIDER" == "github" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Workspace : $(basename "$WORKSPACE_DIR")"
  echo "  Expected  : github.com/$GH_USER"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # 1. Already the active account?
  current_user="$(gh api user --jq .login 2>/dev/null || true)"
  if [[ "$(echo "$current_user" | tr '[:upper:]' '[:lower:]')" == "$(echo "$GH_USER" | tr '[:upper:]' '[:lower:]')" ]]; then
    echo "  Already authenticated as $GH_USER, skipping login."
  # 2. Account stored but not active — try switching
  elif gh auth switch --user "$GH_USER" 2>/dev/null; then
    echo "  Switched gh account to $GH_USER."
  # 3. Not found — full login
  else
    echo "  Account $GH_USER not found. Running: gh auth login"
    gh auth login
  fi

  while IFS= read -r repo || [[ -n "$repo" ]]; do
    repo="${repo%%\#*}"           # strip comments
    repo="${repo//[[:space:]]/}"  # trim whitespace
    [[ -z "$repo" ]] && continue
    dest="$WORKSPACE_DIR/$(basename "$repo")"
    if [[ -d "$dest" ]]; then
      echo "  exists  $dest"
    else
      gh repo clone "$repo" "$dest"
      echo "  cloned  $dest"
    fi
  done < "$LIST_FILE"
fi

# ── Git-over-SSH workspace ─────────────────────────────────────────────────────
# Uses the host alias and key configured in ssh/config (Host my-git-server).
# The example targets Azure DevOps, which requires an RSA key.

if [[ "$PROVIDER" == "ssh" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Workspace : $(basename "$WORKSPACE_DIR")"
  echo "  Provider  : git over SSH"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  SSH_KEY="$HOME/.ssh/id_rsa_work"
  if [[ -f "$SSH_KEY" ]]; then
    echo "  SSH key already exists at $SSH_KEY"
  else
    echo "  Generating a dedicated RSA SSH key for your work git host..."
    read -rp "  Enter your email address: " ssh_email
    bash "$DOTFILES/scripts/ssh.sh" "$ssh_email" "id_rsa_work" "work git host" "rsa"
    echo ""
    echo "  !! Add the public key above to your git host before continuing"
    echo "     (Azure DevOps: https://dev.azure.com/<your-org>/_usersSettings/keys)"
    echo ""
    read -rp "  Press Enter once you've added the key... "
  fi

  echo "  Testing SSH connection to my-git-server..."
  if ssh -T git@my-git-server -o ConnectTimeout=10 2>&1 | grep -q "authenticated"; then
    echo "  SSH connection OK"
  else
    echo "  Warning: SSH test inconclusive — not every host returns a success message like GitHub."
    echo "  Proceeding anyway; clone will fail if auth is not set up correctly."
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%\#*}"  # strip comments
    [[ -z "${line//[[:space:]]/}" ]] && continue
    ssh_url="$(echo "$line" | awk '{print $1}')"
    dest_name="$(echo "$line" | awk '{print $2}')"
    dest="$WORKSPACE_DIR/$dest_name"
    if [[ -d "$dest" ]]; then
      echo "  exists  $dest"
    else
      git clone "$ssh_url" "$dest"
      echo "  cloned  $dest"
    fi
  done < "$LIST_FILE"
fi
