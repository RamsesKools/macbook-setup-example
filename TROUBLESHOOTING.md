# Troubleshooting

Known issues and their fixes. These are not applied automatically by `fresh.sh` — apply manually when you hit the problem.

## az Bicep deployment failing with SSL certificate error

**Symptoms:**

`az deployment group create` fails because the Azure CLI can't find the Bicep CLI and tries to download it automatically. The download then fails with:

```
Error while attempting to download Bicep CLI: <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED]
certificate verify failed: self-signed certificate in certificate chain (_ssl.c:1032)>
```

**Why it happens:**

`az deployment group create` requires the Bicep CLI and expects to manage its own copy at `~/.azure/bin/bicep`. On corporate networks with self-signed certificates, the automatic download via `az bicep install` fails because the Azure CLI doesn't respect the system certificate chain for that request (known bug, see [issue #19420](https://github.com/Azure/azure-cli/issues/19420)).

**Fix:**

Install Bicep via Homebrew (which handles the download fine) and symlink it to where `az` expects it:

```sh
brew install azure/bicep/bicep
mkdir -p ~/.azure/bin
ln -sf /opt/homebrew/bin/bicep ~/.azure/bin/bicep
az bicep version  # should now print the version
```

This is the same approach Microsoft documents for air-gapped environments.

**Note:** Use `brew upgrade bicep` to update, not `az bicep upgrade` — the upgrade command will try to re-download and hit the same SSL error.
