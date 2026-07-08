#!/usr/bin/env bash
# fresh.sh — bootstrap a new Mac from this dotfiles repo.
# Safe to re-run: every step checks before acting.
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_DIR="$DOTFILES/.backups/$TS"

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '    \033[0;32mok\033[0m  %s\n' "$*"; }

# ── sudo keepalive ─────────────────────────────────────────────────────────────
# Ask for sudo upfront so cask installs (logi-options+, linearmouse, etc.)
# never prompt mid-output during brew bundle.

printf '\n\033[1;33mWARNING: this script requires sudo permissions to configure your system and install all apps. Make sure you understand what this script does.\033[0m\n\n'
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ── helpers ────────────────────────────────────────────────────────────────────

link() {
  local target="$1" link_path="$2"

  if [[ -L "$link_path" ]]; then
    local current; current="$(readlink "$link_path")"
    if [[ "$current" == "$target" ]]; then
      ok "$link_path -> $target"
      return
    fi
    info "relinking $link_path (was -> $current)"
    rm "$link_path"
  elif [[ -e "$link_path" ]]; then
    mkdir -p "$BACKUP_DIR"
    local rel="${link_path#"$HOME/"}"
    local dest="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$link_path" "$dest"
    info "backed up $link_path -> $dest"
  fi

  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path"
  ok "linked $link_path -> $target"
}

# ── 1. Xcode Command Line Tools ────────────────────────────────────────────────

log "Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
  ok "already installed"
else
  info "installing — follow the prompt..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 5; done
  ok "installed"
fi

# ── 2. SSH keys ────────────────────────────────────────────────────────────────

log "SSH keys"
if ls ~/.ssh/id_*.pub &>/dev/null; then
  ok "SSH key(s) already exist — skipping"
else
  read -rp "    Set up a new SSH key? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    bash "$DOTFILES/scripts/ssh.sh"
    read -rp "    Public key copied to clipboard. Add it to GitHub, then press Enter to continue..."
  else
    info "skipped — remember to add SSH keys before cloning private repos"
  fi
fi

# ── 3. Oh My Zsh ───────────────────────────────────────────────────────────────

log "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "already installed"
else
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --unattended
  ok "installed"
fi

# ── 4. Homebrew ────────────────────────────────────────────────────────────────

log "Homebrew"
if command -v brew &>/dev/null; then
  ok "already installed"
  if [[ ! -w /opt/homebrew/Cellar ]]; then
    info "fixing Homebrew ownership..."
    sudo chown -R "$(whoami)" /opt/homebrew
    ok "ownership fixed"
  fi
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "installed"
fi

brew update

# ── 5. Brewfile ────────────────────────────────────────────────────────────────

log "Homebrew bundle (formulae, casks)"
info "this can take some time the first time running depending on your connection..."
brew bundle --file "$DOTFILES/Brewfile"

# ── 6. VS Code extensions ──────────────────────────────────────────────────────

log "VS Code extensions"
bash "$DOTFILES/scripts/vscode-extensions-install.sh" "$DOTFILES/lists/vscode-extensions.txt"

# ── 7. Symlink dotfiles ────────────────────────────────────────────────────────

log "Symlinking dotfiles"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

link "$DOTFILES/zsh/.zshrc"      "$HOME/.zshrc"
link "$DOTFILES/zsh/.zshenv"     "$HOME/.zshenv"
link "$DOTFILES/zsh/.zprofile"   "$HOME/.zprofile"
link "$DOTFILES/zsh/aliases.zsh" "$ZSH_CUSTOM/aliases.zsh"
link "$DOTFILES/zsh/path.zsh"    "$ZSH_CUSTOM/path.zsh"

link "$DOTFILES/git/.gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"

link "$DOTFILES/ssh/config" "$HOME/.ssh/config"

mkdir -p "$HOME/Library/KeyBindings"
link "$DOTFILES/keyboard/DefaultKeyBinding.dict" \
     "$HOME/Library/KeyBindings/DefaultKeyBinding.dict"

mkdir -p "$HOME/.config/linearmouse"
link "$DOTFILES/config/linearmouse/linearmouse.json" \
     "$HOME/.config/linearmouse/linearmouse.json"

mkdir -p "$HOME/.config/gh"
link "$DOTFILES/config/gh/config.yml" "$HOME/.config/gh/config.yml"

VSCODE_USER="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER"
link "$DOTFILES/vscode/settings.json"    "$VSCODE_USER/settings.json"
link "$DOTFILES/vscode/keybindings.json" "$VSCODE_USER/keybindings.json"

# ── 8. NVM + Node ─────────────────────────────────────────────────────────────

log "NVM + Node"
if [[ -d "$HOME/.nvm" ]]; then
  ok "NVM already installed"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
  ok "NVM installed"
fi
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
nvm alias default 22
ok "Node $(node --version) set as default"

# ── 9. npm global packages ────────────────────────────────────────────────────

log "npm global packages"
bash "$DOTFILES/scripts/npm-global-packages.sh" "$DOTFILES/lists/npm-globals.txt"

# ── 10. Python (pyenv) ────────────────────────────────────────────────────────

log "Python (pyenv)"
if ! pyenv versions | grep -q "3.12.7"; then
  pyenv install 3.12.7
fi
pyenv global 3.12.7
ok "Python $(python --version 2>&1) set as global"

# ── 11. Bun ───────────────────────────────────────────────────────────────────

log "Bun"
if command -v bun &>/dev/null; then
  ok "already installed"
else
  curl -fsSL https://bun.sh/install | bash
  ok "installed"
fi

# ── 12. dbt Fusion CLI ───────────────────────────────────────────────────────

log "dbt Fusion CLI"
if command -v dbt &>/dev/null; then
  ok "already installed"
else
  curl -fsSL https://public.cdn.getdbt.com/fs/install/install.sh | sh -s -- --update
  ok "installed"
fi

# ── 13. Claude CLI ───────────────────────────────────────────────────────────

log "Claude CLI"
if command -v claude &>/dev/null; then
  ok "already installed"
else
  curl -fsSL https://claude.ai/install.sh | bash
  ok "installed"
fi

# ── 14. pipx tools ────────────────────────────────────────────────────────────

log "pipx tools"
bash "$DOTFILES/scripts/pipx-install.sh" "$DOTFILES/lists/pipx-tools.txt"

# ── 15. AI agent config (~/.agents) ───────────────────────────────────────────

log "AI agent config"
AGENTS_DIR="$HOME/.agents"
if [[ -d "$AGENTS_DIR" ]]; then
  ok "already cloned"
else
  # Replace <your-username> with your GitHub username (or point at your own agent-config repo)
  git clone "git@github.com:<your-username>/agent-config.git" "$AGENTS_DIR"
  ok "cloned"
fi
if [[ -f "$AGENTS_DIR/scripts/setup-symlinks.sh" ]]; then
  bash "$AGENTS_DIR/scripts/setup-symlinks.sh"
  ok "agent symlinks set up"
fi

# ── 16. Workspace directories + repos ─────────────────────────────────────────

# One call per workspace. github mode authenticates via gh; ssh mode uses
# plain git clone with an SSH key (see ssh/config and workspaces/work.txt).
log "Workspace: personal (GitHub)"
bash "$DOTFILES/scripts/clone-workspace.sh" github "your-username" \
  "$HOME/personal_workspace" "$DOTFILES/workspaces/personal.txt"

log "Workspace: work (git over SSH)"
bash "$DOTFILES/scripts/clone-workspace.sh" ssh \
  "$HOME/work_workspace" "$DOTFILES/workspaces/work.txt"

# ── 15. macOS preferences ─────────────────────────────────────────────────────

log "macOS preferences"
read -rp "    Apply macOS system preferences from macos/.macos? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  # shellcheck source=macos/.macos
  source "$DOTFILES/macos/.macos"
  ok "applied — some changes require a restart"
else
  info "skipped — run 'source ~/.dotfiles/macos/.macos' whenever you're ready"
fi

# ── 16. Verify installation ───────────────────────────────────────────────────

log "Verify installation"
read -rp "    Run verify.sh to check all tools are installed correctly? [Y/n] " ans
if [[ ! "$ans" =~ ^[Nn]$ ]]; then
  # Reload the shell environment so newly installed tools are on PATH
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  export PATH="$HOME/.local/bin:$PATH"
  export PATH="$HOME/.bun/bin:$PATH"
  bash "$DOTFILES/verify.sh"
else
  info "skipped — run 'bash ~/.dotfiles/verify.sh' whenever you're ready"
fi

# ── Done ───────────────────────────────────────────────────────────────────────

log "Done!"
printf '\n\033[1mRemaining manual steps:\033[0m\n'
cat <<'EOF'

  ── Auth ────────────────────────────────────────────────────────────────────
  1. Sign in to GitHub CLI:          gh auth login
  2. Sign in to Azure CLI:           az login
  3. Sign in to Databricks CLI:      databricks auth login
  4. Sign in to Claude:              claude login

  ── SSH keys ────────────────────────────────────────────────────────────────
  5. Copy SSH private keys to ~/.ssh/ and set permissions:
       chmod 600 ~/.ssh/id_*

  ── Background apps (open each once to activate + grant permissions) ────────
  6. AltTab        — open from /Applications, grant Screen Recording permission
  7. LinearMouse   — open from /Applications, grant Accessibility permission
  8. Raycast       — open from /Applications, grant required permissions,
                     then import settings:
                       Raycast > Settings > Advanced > Import

  ── Brave browser ───────────────────────────────────────────────────────────
  9. Migrate profiles from old Mac:
     a. On old Mac — quit Brave, then copy the profile folder:
          ~/Library/Application Support/BraveSoftware/Brave-Browser/
     b. On new Mac — quit Brave if open, replace the same folder
     c. Restart Brave — bookmarks, history and settings should be restored
     d. Reinstall extensions (they don't survive the copy)
     e. Re-import passwords if needed:
          brave://password-manager/settings > Select file

  ── Devices ─────────────────────────────────────────────────────────────────
  10. Reconnect Bluetooth devices (mouse, keyboard, headphones)
  11. Reconnect to Wi-Fi networks
  12. Connect docking stations and external displays — expect to reconfigure
      display layout and keyboard mappings on first connect

  ── Apps ────────────────────────────────────────────────────────────────────
  13. Obsidian — open, then: Open folder as vault > your notes repo
  14. Install any company VPN clients — managed by IT
  15. Install Mac App Store apps from apps/mas.md (if not pre-installed by IT)

  ── Finish ───────────────────────────────────────────────────────────────────
  16. Restart your Mac to finalize all system preference changes

EOF
