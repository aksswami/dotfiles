# dotfiles

Personal macOS dotfiles managed with [chezmoi](https://chezmoi.io). SSH private
keys are pulled from 1Password at apply time — nothing secret is committed here.

## New machine bootstrap

```sh
# 1. Install Homebrew, then the toolchain
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install chezmoi
brew install --cask 1password 1password-cli

# 2. In the 1Password desktop app:
#    Settings → Developer → "Integrate with 1Password CLI" (enable Touch ID unlock)

# 3. Pull and apply everything (prompts 1Password for the SSH keys)
chezmoi init --apply aksswami/dotfiles

# 4. Install all apps/CLIs
brew bundle --file=~/Brewfile

# 5. Re-authenticate GitHub (tokens live in the macOS keychain, not in this repo)
gh auth login
```

## Day-to-day

```sh
chezmoi add <file>     # start tracking a file
chezmoi edit <file>    # edit the source version
chezmoi diff           # preview pending changes
chezmoi apply          # apply source → home
chezmoi cd && git ...  # commit + push from the source repo
```

## Secrets

The two SSH private keys are stored as 1Password **documents** and materialized
by templates (`private_dot_ssh/private_id_ed25519.tmpl`, `..._afklm.tmpl`) via
`onepasswordDocument`. Everything else in `~/.ssh` (config, public keys) is
plaintext-safe and tracked directly.
