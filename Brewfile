# Taps
tap "atlassian/acli", trusted: true
tap "azure/bicep", trusted: true
tap "databricks/tap", trusted: true

# CLI tools
brew "azure-cli"
brew "direnv"        # per-project env vars
brew "ffmpeg"
brew "gh"            # GitHub CLI
brew "jq"
brew "mas"           # Mac App Store CLI
brew "pipx"
brew "pyenv"
brew "ruby"
brew "sqlite"
brew "tree"
brew "unixodbc"
brew "uv"            # fast Python package manager

# Data / cloud
brew "atlassian/acli/acli"
brew "azure/bicep/bicep"
brew "databricks/tap/databricks"
# dbt Fusion CLI — not in homebrew-core; installed via curl in fresh.sh

# Node (base install; NVM manages versions — see fresh.sh)
brew "node"

# Apps — all confirmed available as casks
cask "alt-tab"
cask "beyond-compare"     # diff tool, free to use — see apps/manual.md
# cask "beyond-compare@4" # install v4 instead if your license is for v4 (v4 keys don't work on v5)
cask "brave-browser"
cask "bruno"
cask "codex"
cask "copilot-cli"
cask "dbeaver-community"
cask "drawio"
cask "firefox"
cask "gimp"
cask "linearmouse"
cask "logi-options+"
cask "podman-desktop"
cask "obsidian"
cask "raycast"
cask "rancher"
cask "signal"
cask "spotify"
cask "slack"
cask "visual-studio-code"
cask "whatsapp"

# Mac App Store — work laptop: these are typically pre-installed by IT.
# Uncomment and run `mas install <id>` manually if needed on a personal machine.
# mas "Microsoft Word",        id: 462054704
# mas "Microsoft Excel",       id: 462058435
# mas "Microsoft PowerPoint",  id: 462062816
# mas "Microsoft Outlook",     id: 985367838
# mas "Microsoft OneNote",     id: 784801555
# mas "Microsoft Teams",       id: 1784841823
# mas "OneDrive",              id: 823766827
mas "Azure VPN Client",      id: 1553936137
mas "WireGuard",              id: 1451685025

# VS Code extensions are installed sequentially in fresh.sh to avoid race conditions.
