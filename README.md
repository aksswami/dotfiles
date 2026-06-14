# dotfiles

Personal macOS dotfiles managed with [chezmoi](https://chezmoi.io). SSH private
keys are pulled from 1Password at apply time — nothing secret is committed here.

**What's tracked:** `.zshrc`, `.zprofile`, `.gitconfig`, `.config/git/ignore`,
the full `.config/fish/` setup (config, `conf.d`, custom git functions,
`fish_plugins`), `.ssh/config` + public keys, `Brewfile`, and an opt-in
`~/.local/bin/macos-defaults.sh`.

**Branches:** `main` is the live config. `legacy-holman-2017` archives the old
2017 holman-fork layout (reference only).

---

## New machine setup

```sh
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi + 1Password (needed before the keys can be pulled)
brew install chezmoi
brew install --cask 1password 1password-cli

# 3. In the 1Password DESKTOP app (one-time):
#    Settings → Developer → enable "Integrate with 1Password CLI"
#    (also enable Touch ID unlock). Sign in to your account.
#    Verify from the terminal:
op vault list

# 4. Pull this repo and apply it. The SSH-key templates trigger a 1Password
#    (Touch ID) prompt the first time.
chezmoi init --apply aksswami/dotfiles

# 5. Install every app / CLI / VS Code extension from the Brewfile
brew bundle --file=~/Brewfile

# 6. Re-authenticate GitHub — tokens live in the macOS keychain, not in this repo
gh auth login
```

That's it. `~/.ssh/id_ed25519` and `id_ed25519_afklm` are written with `0600`
perms straight from 1Password — no manual key copying.

---

## Verifying on a new machine

After `chezmoi init --apply`, confirm it pulled and applied everything.

### 1. Did it pull and apply at all?

```sh
chezmoi source-path        # → ~/.local/share/chezmoi
chezmoi git -- remote -v   # → git@github.com:aksswami/dotfiles.git
chezmoi diff               # EMPTY = source and home are in sync ✓
chezmoi status             # EMPTY = nothing pending ✓
chezmoi managed | wc -l    # count of managed paths
```

**Empty `chezmoi diff` + empty `chezmoi status` is the headline "it applied"
signal.** If either prints anything, run `chezmoi apply -v` to finish.

### 2. Did the 1Password secrets resolve? (the important part)

```sh
# SSH private keys present, 0600, non-empty
ls -l ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_afklm
ssh-keygen -y -f ~/.ssh/id_ed25519 >/dev/null && echo "key valid ✓"

# Claude Portkey key got injected, and the file is not world-readable
grep -o 'x-portkey-api-key: .\{6\}' ~/.claude/settings.json
ls -l ~/.claude/settings.json        # -rw------- (0600)

# End-to-end: GitHub over SSH
ssh -T git@github.com                 # "Hi aksswami! ..."
```

If any secret file is **empty** or you see an **`op signin` / authorization
error**, 1Password wasn't unlocked when chezmoi applied. Unlock the 1Password
app, then re-run `chezmoi apply`.

### 3. Spot-check real files landed

```sh
git config --global user.email                 # your identity
functions gwip                                 # a tracked fish git function exists
ls ~/.local/bin/macos-defaults.sh              # opt-in script present
head -3 "$HOME/Library/Application Support/Code/User/settings.json"
```

> Preview what *would* change without touching anything:
> `chezmoi diff` or `chezmoi apply --dry-run -v`.

---

## Keeping dotfiles up to date

chezmoi has a **source repo** (`~/.local/share/chezmoi`, this Git repo) and your
**home directory** (the live files). Changes flow in two directions; chezmoi does
**not** sync automatically, so pick the matching command.

### A. You changed a config in `$HOME` → save it to the repo

When you edit a tracked file directly (e.g. tweak `~/.config/fish/config.fish`):

```sh
chezmoi re-add               # pull ALL tracked files' current home state into the source
# — or, for a single file —
chezmoi add ~/.config/fish/config.fish

chezmoi cd                   # jump into the source repo
git add -A
git commit -m "feat(fish): add foo abbreviation"
git push
exit                         # leave the source repo shell
```

> `chezmoi add` also **starts tracking a brand-new file**. `chezmoi re-add` only
> refreshes files already tracked (it won't pick up new ones).

To edit through chezmoi instead (writes straight to the source, then applies):

```sh
chezmoi edit --apply ~/.zshrc
```

### B. The repo changed (another Mac, or you edited the source) → update `$HOME`

```sh
chezmoi update               # = git pull in the source, then apply to home
```

Prefer to look before you leap:

```sh
chezmoi git pull             # fetch latest source only
chezmoi diff                 # preview what would change in $HOME
chezmoi apply                # apply source → home
```

### Routine check

```sh
chezmoi diff                 # empty output = home and repo are in sync
chezmoi status               # short per-file status (like git status)
chezmoi managed              # list every path chezmoi controls
```

### Keep the Brewfile current

The Brewfile is tracked, so refresh it after installing/removing apps:

```sh
brew bundle dump --force --file=~/Brewfile   # regenerate from what's installed
chezmoi re-add ~/Brewfile && chezmoi cd && git commit -am "chore: update Brewfile" && git push && exit
```

---

## Command reference

| Command | What it does |
| --- | --- |
| `chezmoi add <file>` | Start tracking a file (home → source) |
| `chezmoi re-add` | Refresh all tracked files from home → source |
| `chezmoi edit [--apply] <file>` | Edit the source version of a file |
| `chezmoi diff` | Preview pending source → home changes |
| `chezmoi status` | Short status of managed files |
| `chezmoi apply` | Apply source → home |
| `chezmoi update` | `git pull` + `apply` in one step |
| `chezmoi git -- <args>` | Run git inside the source repo |
| `chezmoi cd` | Open a shell in the source repo |
| `chezmoi cat <file>` | Print the rendered output of a file |

---

## Secrets

The two SSH private keys are stored as 1Password **documents** (vault `Private`,
titled `ssh_id_ed25519` and `ssh_id_ed25519_afklm`) and materialized by templates
(`private_dot_ssh/private_id_ed25519.tmpl`, `..._afklm.tmpl`) via
`onepasswordDocument`. Everything else in `~/.ssh` (config, public keys) is
plaintext-safe and tracked directly.

To rotate or add a key: update/create the 1Password document, then point a
template at it. GitHub tokens are intentionally **not** stored here — they live in
the macOS keychain; run `gh auth login` per machine.
