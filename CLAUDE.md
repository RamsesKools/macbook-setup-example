# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS dotfiles and bootstrap repo. The goal is a single `bash fresh.sh` to go from a fresh Mac to a fully configured machine. Inspired by [driesvints/dotfiles](https://github.com/driesvints/dotfiles).

The repo lives in a workspace directory and is symlinked to `~/.dotfiles`.

## Key scripts

User-facing scripts (run these directly):

- `fresh.sh` — main bootstrap, runs once on a new Mac. Steps: Xcode CLT → SSH keys → Oh My Zsh → Homebrew → Brewfile → VS Code extensions → symlinks → NVM/Node/npm globals → pyenv/Python → Bun → pipx tools → AI agent config → workspace clones → macOS prefs → verify
- `verify.sh` — run after setup to check all tools. Prints `[ok]`/`[fail]` per check, exits 1 on any failure

Helper scripts in `scripts/` (called by `fresh.sh`, but can also be run standalone):

- `scripts/ssh.sh` — generates ed25519 or RSA SSH keys, adds to macOS keychain. Args: `<email> <keyname> <label> <algorithm>`
- `scripts/vscode-extensions-install.sh` — installs VS Code extensions sequentially from a list file. Args: `<list-file>`
- `scripts/clone-workspace.sh` — clones repos for one workspace from a list file. Args: `github <gh-user> <workspace-dir> <list-file>` or `ssh <workspace-dir> <list-file>`

## List files

Edit these to add/remove items — one per line, `#` for comments:

- `lists/vscode-extensions.txt` — VS Code extension IDs
- `lists/npm-globals.txt` — npm global packages
- `lists/pipx-tools.txt` — pipx tools

## Workspace files

Edit these to add/remove repos — one `org/repo` per line (GitHub), or `ssh-url  dest-folder` per line (git over SSH):

- `workspaces/personal.txt` — personal GitHub repos
- `workspaces/work.txt` — work repos on a git host over SSH

## Architecture decisions

**Symlinking**: `fresh.sh` symlinks all config files from the repo to their expected locations using the `link()` helper, which backs up any existing file before replacing it. Never edit `~/.zshrc` etc. directly — edit the files in this repo.

**Auth model**: GitHub workspaces use `gh auth login` (no SSH keys for GitHub). Git hosts without a CLI (e.g. Azure DevOps) use a dedicated SSH key (`~/.ssh/id_rsa_work`). The `~/.agents` clone is the exception — still uses SSH.

**SSH key naming convention**: `id_<algorithm>_<context>` (e.g. `id_ed25519_my_server`, `id_rsa_work`).

**dbt**: dbt Fusion CLI, installed via curl in `fresh.sh` (not in homebrew-core). `dbtf` is an alias for `dbt`. Manual install: `curl -fsSL https://public.cdn.getdbt.com/fs/install/install.sh | sh -s -- --update`

**pipx tools**: poetry, pre-commit, sqlfluff. dbt-core companions (dbt-jobs-as-code etc.) are commented out — install per project if needed.

## Config files in this repo

| Repo path | Symlinked to |
| --- | --- |
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zshenv` | `~/.zshenv` |
| `zsh/.zprofile` | `~/.zprofile` |
| `zsh/aliases.zsh` | `$ZSH_CUSTOM/aliases.zsh` |
| `zsh/path.zsh` | `$ZSH_CUSTOM/path.zsh` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/.gitignore_global` | `~/.gitignore_global` |
| `ssh/config` | `~/.ssh/config` |
| `keyboard/DefaultKeyBinding.dict` | `~/Library/KeyBindings/DefaultKeyBinding.dict` |
| `config/linearmouse/linearmouse.json` | `~/.config/linearmouse/linearmouse.json` |
| `config/gh/config.yml` | `~/.config/gh/config.yml` |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `vscode/keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json` |

## What is NOT in this repo

- SSH private keys (`~/.ssh/id_*`)
- AI agent config — lives in a separate `~/.agents` repo (`<your-username>/agent-config`)
- Machine-specific paths — all configs use `$HOME`, never `/Users/<you>`
