# macbook-setup-example

> **Note**: this is a depersonalized example snapshot of my real MacBook setup, published alongside my [computer setup blog post](https://blog.ramseskools.nl/computer-setup).
> Names, emails, hosts, and repo lists have been replaced with generic placeholders, and it is not actively maintained.

Dotfiles and bootstrap scripts for setting up a new Mac from scratch.
Inspired by [driesvints/dotfiles](https://github.com/driesvints/dotfiles) and [dotfiles.github.io](https://dotfiles.github.io/).

On a fresh machine it should be cloned to `~/.dotfiles` directly (or symlinked there after cloning to the workspace).

## What's in here

```text
fresh.sh              bootstrap script — run this once on a new Mac
verify.sh             check all tools are installed correctly

scripts/
  ssh.sh              SSH key generation helper
  vscode-extensions-install.sh   install VS Code extensions sequentially
  clone-workspace.sh  clone all repos for a single workspace

lists/
  vscode-extensions.txt   VS Code extension IDs (one per line)
  npm-globals.txt         npm global packages (one per line)
  pipx-tools.txt          pipx tools (one per line)

workspaces/
  personal.txt            personal GitHub repos
  work.txt                work repos on a git host over SSH

Brewfile              Homebrew formulae and casks
zsh/                  shell config (.zshrc, .zshenv, .zprofile, aliases, path)
git/                  .gitconfig and .gitignore_global
ssh/                  SSH host config (no private keys)
keyboard/             macOS key binding overrides (Home/End behaviour)
config/               tool configs (linearmouse, gh CLI)
vscode/               VS Code settings and keybindings
macos/                macOS system preference scripts (review before running)
apps/                 docs for apps that need manual install or sign-in
```

## Setting up a new Mac

### Before you start

- Update macOS to the latest version via System Settings.
- Have your SSH key(s) or email address ready for the SSH step.

### Steps

1. Clone this repo to `~/.dotfiles`:

   ```sh
   git clone https://github.com/RamsesKools/macbook-setup-example.git ~/.dotfiles
   # (or your own fork/copy of it)
   # TODO Solve chicken and egg problem of needing gh, but installing it with this repo's script.
   ```

2. Run the bootstrap script:

   ```sh
   cd ~/.dotfiles
   bash fresh.sh
   ```

   `fresh.sh` will walk you through each step interactively.
   It is idempotent — safe to re-run if something fails partway through.

3. Finish the manual steps printed at the end of `fresh.sh`:
   - Sign in to GitHub CLI, Azure CLI, Databricks CLI, Claude.
   - Copy SSH private keys and run `ssh-add`.
   - Install any company VPN clients via your IT helpdesk.
   - Restart your Mac.

### AI agent config

AI agent configuration (Claude Code, Codex, GitHub Copilot CLI) lives in a separate `~/.agents` repo.
`fresh.sh` prompts you to clone it and runs its `setup-symlinks.sh` automatically.

### macOS preferences

The `macos/.macos` script applies `defaults write` system preferences.
`fresh.sh` asks before running it. You can also run it manually at any time:

```sh
source ~/.dotfiles/macos/.macos
```

See [macos/.macos](macos/.macos) for the full list of settings applied.

## Verification

Run after setup to confirm everything is working:

```sh
bash ~/.dotfiles/verify.sh
```

Each check prints `[ok]` or `[fail]` with a label. A summary at the end shows the total pass/fail count.

Manual checks not covered by the script:

- LinearMouse: open the app and confirm mouse settings are applied.
- VS Code: open and confirm extensions are loaded.

## Running individual steps manually

You don't need to re-run `fresh.sh` to install one thing. Each step can be run independently:

**Install VS Code extensions:**

```sh
bash ~/.dotfiles/scripts/vscode-extensions-install.sh ~/.dotfiles/lists/vscode-extensions.txt
```

**Install npm global packages:**

```sh
bash ~/.dotfiles/scripts/npm-global-packages.sh ~/.dotfiles/lists/npm-globals.txt
```

**Install pipx tools:**

```sh
bash ~/.dotfiles/scripts/pipx-install.sh ~/.dotfiles/lists/pipx-tools.txt
```

**Clone repos for one workspace:**

```sh
# GitHub workspace
bash ~/.dotfiles/scripts/clone-workspace.sh github <gh-username> ~/personal_workspace ~/.dotfiles/workspaces/personal.txt

# Git-over-SSH workspace (SSH key must already exist)
bash ~/.dotfiles/scripts/clone-workspace.sh ssh ~/work_workspace ~/.dotfiles/workspaces/work.txt
```

**Generate an SSH key:**

```sh
bash ~/.dotfiles/scripts/ssh.sh                                              # default ed25519
bash ~/.dotfiles/scripts/ssh.sh you@example.com id_rsa_work "Label" rsa      # custom RSA key
```

## Notable choices

### gh auth instead of SSH keys for GitHub

Workspace cloning authenticates GitHub through `gh auth login`, not SSH keys.
I almost only work with GitHub and often switch between multiple GitHub accounts, which `gh auth switch` handles well — juggling multiple accounts with SSH keys doesn't really work.
Hosts without a CLI like gh (Azure DevOps, self-hosted git) use plain `git clone` over SSH instead: see the ssh mode of [scripts/clone-workspace.sh](scripts/clone-workspace.sh) and the host aliases in [ssh/config](ssh/config).

### Home and End keys (keyboard/)

External keyboards with Home and End keys don't behave as expected on macOS: they jump through the document instead of to the start or end of the line.
[keyboard/DefaultKeyBinding.dict](keyboard/DefaultKeyBinding.dict) rebinds them to line start/end, including shift-selection.
`fresh.sh` symlinks it into `~/Library/KeyBindings/`.

### LinearMouse (config/linearmouse/)

I started using LinearMouse because macOS wouldn't let me disable pointer acceleration, and years of point-and-click games (osu!, Counter-Strike, League of Legends) taught me to aim with a mouse without acceleration.
macOS can disable acceleration natively these days (since a few years), but its mouse customization is still lacking, so LinearMouse stays.

## Keeping this up to date

When you install something new or change a setting:

- Add new Homebrew packages/casks to `Brewfile`.
- Add new VS Code extensions to `lists/vscode-extensions.txt`.
- Add new npm globals to `lists/npm-globals.txt`.
- Add new pipx tools to `lists/pipx-tools.txt`.
- Add repos to the relevant file in `workspaces/`.
- Update shell files in `zsh/` instead of editing `~/.zshrc` directly (they're symlinked).
- Update `vscode/settings.json` here; it's symlinked to VS Code's config dir.
- Commit and push so any future machine stays in sync.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for known issues and fixes.

## Linux / Windows

This repo is macOS-only for now. The `Brewfile`, `apps/mas.md`, and `apps/manual.md`
document all tools installed, making it easier to write equivalent setup scripts for other platforms later.
