#!/usr/bin/env bash
# verify.sh — check that all tools from fresh.sh are working correctly.
set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

PASS=0
FAIL=0

ok()   { echo -e "  ${GREEN}[ok]${RESET}   $1"; ((PASS++)); }
fail() { echo -e "  ${RED}[fail]${RESET} $1"; ((FAIL++)); }

check() {
  local label="$1"; shift
  if "$@" &>/dev/null; then
    ok "$label"
  else
    fail "$label"
  fi
}

echo ""
echo "Verifying setup..."
echo ""

# Shell
check "zsh"             zsh -i -c 'exit 0'

# Homebrew
check "brew"            brew --version
check "brew bundle"     brew bundle check --file "$HOME/.dotfiles/Brewfile" --no-upgrade

# Git
check "git user.name"   git config --global user.name

# Node / npm
check "node"            node --version
check "npm"             npm --version
check "nvm"             bash -c 'source "$NVM_DIR/nvm.sh" && nvm --version'

# Python
check "pyenv"           pyenv --version
check "python"          python --version
check "uv"              uv --version
check "poetry"          poetry --version
check "pipx"            pipx --version
check "pre-commit"      pre-commit --version
check "sqlfluff"        sqlfluff --version

# Bun
check "bun"             bun --version

# VS Code
check "code"            code --version
check "vscode extensions" bash -c '[[ $(code --list-extensions | wc -l) -gt 0 ]]'

# GitHub CLI
check "gh auth"         gh auth status

# Cloud / data tools
check "azure-cli"       az --version
check "databricks"      databricks --version
check "dbt"             dbt --version

# Claude CLI
check "claude"          claude --version

# Docker / Rancher
check "docker"          docker info

# direnv
check "direnv"          direnv --version

# jq
check "jq"              jq --version

# SSH keys (adjust to the keys you actually use — see ssh/config)
check "ssh key: my-server" test -f "$HOME/.ssh/id_ed25519_my_server"
check "ssh key: work git"  test -f "$HOME/.ssh/id_rsa_work"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Passed : $PASS"
echo "  Failed : $FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [[ $FAIL -gt 0 ]]; then
  echo "  Some checks failed. Review the [fail] lines above."
  echo ""
  exit 1
fi
