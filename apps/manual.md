# Apps and steps that require manual action

## VPNs

### Company VPNs

Managed by IT — not self-installable.
Whatever VPN clients your employer or clients require are usually pre-installed or documented by their IT department.

### WireGuard (personal VPN, optional)

I run WireGuard as my personal VPN into my home network — skip this if that's not your setup.
Installed via `mas install 1451685025` (handled by `brew bundle`).
Tunnel configs are not stored in this repo — import them manually:

1. Open WireGuard.
2. Click "Import tunnel(s) from file" and select your `.conf` file.
3. Activate the tunnel to connect to your home network.

Your tunnel config lives on your home server or a secure backup — retrieve it from there.

## Raycast

Raycast is my Spotlight replacement and one of my favorite tools — I wrote about why in [this post](https://blog.ramseskools.nl/likes/raycast/).
The customizations I lean on most: window snapping on `control + command + left/right`, clipboard history that survives restarts, and volume control on `control + shift + up/down`.

Installed via `brew install --cask raycast`.
Settings contain credentials so they are not stored in this repo — move them between machines instead:

1. On the old machine: Raycast menu > Export Settings > save the `.rayconfig` file.
2. On the new machine: Raycast menu > Import Settings > select the `.rayconfig` file.

## Brave profiles

I use a separate Brave profile per context: one for private stuff and one per company I work for.
That keeps logins, bookmarks, extensions, and history cleanly separated.
Create them via the Brave menu > Add new profile.
Steps for migrating profiles from an old Mac are printed at the end of `fresh.sh`.

## Beyond Compare

Beyond Compare is my favorite diff tool.
You can use it freely, but I'm a big fan so I bought a license.
That license is for version 4 and does not carry over to version 5 — hence the commented `beyond-compare@4` option in the `Brewfile`.

If you have a v4 license, install `beyond-compare@4` and enter the key manually:

1. Open Beyond Compare 4.
2. Go to Beyond Compare > Enter Key.
3. Enter your license key (version 4 key, build 28397 or newer v4).

## Obsidian

I use Obsidian for all note-taking.
For me it is just Markdown files in a git repo, so notes are versioned and portable — the app is a nice editor on top.

### Plugin settings

TODO: update `.obsidian/.gitignore` in the vault repo to track `data.json` (plugin settings) and stop tracking plugin binaries (`main.js`, `manifest.json`, `styles.css`).

Do this on the old (configured) Mac:

1. Update `.gitignore`:

   ```gitignore
   .obsidian/plugins/*/*
   !.obsidian/plugins/*/data.json
   # keep sensitive plugins ignored:
   .obsidian/plugins/obsidian-git/data.json
   .obsidian/plugins/smart-connections/data.json
   .obsidian/plugins/maps/data.json
   ```

2. Remove plugin binaries from git: `git rm -r --cached .obsidian/plugins/`
3. Stage and commit the `data.json` files: `git add .obsidian/ && git commit`
4. On the new Mac: `git pull` — Obsidian will reinstall plugin binaries on first open.

## Outlook

Work account is pre-configured by IT. Add personal accounts manually:

1. Open Outlook > Settings > Accounts > Add account.
2. Add each personal account (e.g. `you@example.com`).

## Sign-in steps (can't be scripted)

*Optionally* run these after `fresh.sh` completes, or whenever you need to use these apps.

```sh
az login                         # Azure CLI
databricks auth login            # Databricks CLI
claude login                     # Claude CLI
```

For Azure DevOps, configure SSH or personal access tokens per project.
For Databricks, follow the OAuth browser flow that `databricks auth login` opens.

### Messaging apps

**Slack** — log in to each workspace manually:

1. Open Slack.
2. Click "Sign in to a workspace" and authenticate with your email or SSO.
3. Repeat for each workspace (personal, work, etc.).

**Signal**:

1. Open Signal.
2. On your phone: Settings > Linked Devices > Link New Device.
3. Scan the QR code shown in the Signal desktop app.

**WhatsApp** — installed via `brew install --cask whatsapp`:

1. Open WhatsApp.
2. On your phone: WhatsApp > Settings > Linked Devices > Link a Device.
3. Scan the QR code shown in the WhatsApp desktop app.

## SSH keys

Private keys are never stored in this repo.
The naming convention is `id_<algorithm>_<context>`.

### My server (`id_ed25519_my_server`)

Used to SSH into a private server (home server, VPS).

1. Generate: `bash ssh.sh <email> id_ed25519_my_server "My Server"`
2. Add the public key to the server: `ssh-copy-id -i ~/.ssh/id_ed25519_my_server.pub youruser@192.0.2.10`

### Work git host (`id_rsa_work`)

RSA 4096 key, used by `clone-workspace.sh` in ssh mode (Azure DevOps requires RSA). Generated automatically when missing.

1. `clone-workspace.sh` generates the key and prompts you to add it.
2. Add the public key to your git host (Azure DevOps: `https://dev.azure.com/<your-org>/_usersSettings/keys`).
