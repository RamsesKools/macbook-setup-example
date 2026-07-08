#!/usr/bin/env bash
# ssh.sh — generate an ed25519 SSH key and add it to the agent.
#
# Usage:
#   bash ssh.sh                                        # default: ed25519 key at ~/.ssh/id_ed25519
#   bash ssh.sh [email] [keyname] [label] [algorithm]  # custom key name, label, and algorithm
#
# Examples:
#   bash ssh.sh you@example.com id_rsa_work "Azure DevOps" rsa
set -euo pipefail

EMAIL="${1:-}"
KEY_NAME="${2:-id_ed25519}"
LABEL="${3:-GitHub}"
ALGO="${4:-ed25519}"

if [[ -z "$EMAIL" ]]; then
  read -rp "Enter your email address for the SSH key: " EMAIL
fi

KEY_FILE="$HOME/.ssh/$KEY_NAME"

if [[ -f "$KEY_FILE" ]]; then
  echo "SSH key already exists at $KEY_FILE — skipping generation."
else
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  keygen_args=(-t "$ALGO" -C "$EMAIL" -f "$KEY_FILE" -N "")
  [[ "$ALGO" == "rsa" ]] && keygen_args+=(-b 4096)
  ssh-keygen "${keygen_args[@]}"
  echo "SSH key generated: $KEY_FILE"
fi

# Add to ssh-agent (macOS keychain if available)
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain "$KEY_FILE" 2>/dev/null || ssh-add "$KEY_FILE"

# Copy public key to clipboard
pbcopy < "${KEY_FILE}.pub"
echo ""
echo "Public key copied to clipboard. Add it to $LABEL."
echo ""
cat "${KEY_FILE}.pub"
