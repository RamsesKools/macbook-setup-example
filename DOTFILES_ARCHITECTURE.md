# Dotfiles architecture: Stow + XDG approach

This document explores how [GNU Stow](https://www.gnu.org/software/stow/) and the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) can scale and organize this repo.

## The problem

Over time, dotfiles accumulate across your home directory:

```
~
├── .zshrc
├── .zshenv
├── .zprofile
├── .gitconfig
├── .gitignore_global
├── .ssh/
├── .config/
│   ├── gh/
│   ├── linearmouse/
│   └── ...
└── Library/Application Support/Code/User/
```

This becomes messy to manage as more tools add their own config files. XDG Base Directory Spec solves this by centralizing configs in standard locations.

## XDG Base Directory Specification

XDG defines standard locations for user data:

```
~/.config/            → $XDG_CONFIG_HOME  (application configs)
~/.local/share/       → $XDG_DATA_HOME    (application data)
~/.cache/             → $XDG_CACHE_HOME   (temporary cache)
~/.local/state/       → $XDG_STATE_HOME   (application state)
```

Instead of:
```
~/.zshrc
~/.gitconfig
~/.ssh/config
```

You get:
```
~/.config/zsh/zshrc
~/.config/git/config
~/.config/ssh/config
```

**Benefits:**
- Home directory stays clean
- Configs organized by tool in one place
- Portable — can override `$XDG_*_HOME` on different machines
- Standard — tools increasingly support XDG natively

**On macOS:**
- Most tools use XDG, but some still default to home-root dotfiles (zsh, bash, git)
- Some tools require env vars or config flags to enable XDG support
- All can be configured to use XDG with small setup changes

**Tools in this repo that support XDG:**
- `gh` – reads from `~/.config/gh/` (already used here)
- `linearmouse` – reads from `~/.config/linearmouse/` (already used here)
- `git` – supports `~/.config/git/` (needs `core.hooksPath` config)
- `ssh` – can use `~/.config/ssh/config` (needs `Include ~/.config/ssh/config` in `~/.ssh/config`)
- `zsh` – does not support XDG natively; stays at `~/.zshrc`/`~/.zshenv`
- `vscode` – does not use XDG; lives at `~/Library/Application Support/Code/` (macOS-specific)
- `npm` – supports `~/.config/npm/` (via `npm config`)

## GNU Stow

GNU Stow is a symlink farm manager. It mirrors your repo's directory structure in your home directory, creating symlinks automatically.

**Example:**

Repo structure:
```
dotfiles/
├── zsh/
│   ├── .zshrc
│   └── .zshenv
├── git/
│   └── .config/git/config
└── ssh/
    └── .config/ssh/config
```

Run `stow zsh git ssh` from the dotfiles directory, and Stow creates:
```
~
├── .zshrc          → symlink to dotfiles/zsh/.zshrc
├── .zshenv         → symlink to dotfiles/zsh/.zshenv
├── .config/
│   ├── git/config  → symlink to dotfiles/git/.config/git/config
│   └── ssh/config  → symlink to dotfiles/ssh/.config/ssh/config
```

**Benefits:**
- No manual symlinking code needed
- Adding new configs just works
- Reversible — `stow -D` removes all symlinks
- Conflict detection — warns if target files already exist
- Scales well to many config files

**Downsides:**
- Requires Stow as a dependency (trivial — it's in Homebrew)
- Learning curve is minimal but non-zero

## Stow + XDG together

Using both together gives you a clean, scalable setup:

1. Organize configs by tool, mirroring home directory structure
2. Use XDG standard locations where tools support them
3. Use Stow to create all symlinks in one go

**Repository structure:**
```
dotfiles/
├── zsh/                          # Stays at ~ (no XDG support)
│   ├── .zshrc
│   ├── .zshenv
│   └── .zprofile
├── git/
│   └── .config/git/
│       └── config
├── ssh/
│   └── .config/ssh/
│       └── config
├── gh/
│   └── .config/gh/
│       └── config.yml
├── linearmouse/
│   └── .config/linearmouse/
│       └── linearmouse.json
├── vscode/
│   └── Library/Application Support/Code/User/
│       ├── settings.json
│       └── keybindings.json
└── keyboard/
    └── Library/KeyBindings/
        └── DefaultKeyBinding.dict
```

**Setup in fresh.sh:**
```sh
# Install Stow
brew install stow

# Create symlinks for all tool configs
cd ~/.dotfiles
stow zsh git ssh gh linearmouse vscode keyboard
```

**Cleanup:**
```sh
cd ~/.dotfiles
stow -D zsh git ssh gh linearmouse vscode keyboard
```

## Migration path

If you want to adopt this approach:

1. Install Stow: `brew install stow`

2. Reorganize the repo to mirror home directory structure (mostly already done)

3. Update configs to point to XDG locations where supported:
   - Git: add `includeIf.gitdir:~` in `~/.config/git/config` to load tool-specific configs
   - SSH: add `Include ~/.config/ssh/config` in `~/.ssh/config`
   - npm: set via `npm config set`

4. Update `fresh.sh`:
   - Replace all `link()` calls with `cd ~/.dotfiles && stow <packages>`
   - Much simpler and less error-prone

5. Add XDG env var setup to `~/.zshenv`:
   ```sh
   export XDG_CONFIG_HOME="$HOME/.config"
   export XDG_DATA_HOME="$HOME/.local/share"
   export XDG_CACHE_HOME="$HOME/.cache"
   export XDG_STATE_HOME="$HOME/.local/state"
   ```

## Decision: when to adopt

**Start with Stow + XDG if:**
- Your home directory is cluttered and you want to clean it up
- You plan to add more tool configs over time
- You value simplicity in symlinking logic

**Stick with the current approach if:**
- You have fewer than 10 config files
- You're not bothered by dotfiles in `~`
- You prefer explicit control over automatic symlinking

Given that macOS-specific tool locations (`~/Library/`) will always exist, the benefit is mainly for Linux-style config management. But organizing around XDG standards makes the repo more portable and future-proof.

## References

- [GNU Stow manual](https://www.gnu.org/software/stow/manual/)
- [XDG Base Directory Spec](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [XDG Base Directory Support](https://wiki.archlinux.org/title/XDG_Base_Directory) (detailed per-tool guide)
- [driesvints/dotfiles](https://github.com/driesvints/dotfiles) (inspiration for this repo)
