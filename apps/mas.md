# Mac App Store apps

These are typically **pre-installed by IT** on work laptops.
Verify before installing manually — you may already have them.

To install via CLI: `mas install <id>`

| App | MAS ID | Notes |
| --- | --- | --- |
| Microsoft Word | 462054704 | IT-managed |
| Microsoft Excel | 462058435 | IT-managed |
| Microsoft PowerPoint | 462062816 | IT-managed |
| Microsoft Outlook | 985367838 | IT-managed |
| Microsoft OneNote | 784801555 | IT-managed |
| Microsoft Teams | 1784841823 | IT-managed |
| OneDrive | 823766827 | IT-managed |
| Azure VPN Client | 1553936137 | install via App Store if not pre-installed |
| WireGuard | 1451685025 | VPN tunnel to home network |

The Microsoft 365 apps are also commented out in the `Brewfile` for reference.
Uncomment them if you want `brew bundle` to manage them on a personal machine.
