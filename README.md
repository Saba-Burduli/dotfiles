# dotfiles

Reproducible, public macOS developer preferences. The repository is organized by topic: directly managed files use the familiar `.symlink` convention, while `dot` provides a single safe setup interface.

## Install as a package

The repository includes a Homebrew tap formula named `saba-dotfiles`. It installs
the `dot` command and keeps managed links pointed at Homebrew's stable `opt`
path, so `brew upgrade` does not leave broken symlinks.

```bash
brew tap Saba-Burduli/dotfiles
brew install saba-dotfiles
dot bootstrap --dry-run
dot bootstrap --yes
```

It is also published to GitHub Packages as `@saba-burduli/dotfiles`:

```bash
npm install --global @saba-burduli/dotfiles --registry=https://npm.pkg.github.com
dot bootstrap --dry-run
```

The package contains the same portable configuration and `dot` command. The
first `v*` tag publishes its matching package version through GitHub Actions.

Use a normal clone when you plan to edit settings or run `dot sync --from-machine`:

```bash
git clone https://github.com/Saba-Burduli/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./script/dot sync --from-machine --yes
```

## Fresh-Mac setup from a clone

```bash
git clone https://github.com/Saba-Burduli/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./script/dot bootstrap --dry-run
./script/dot bootstrap --yes
./script/dot doctor
```

`script/bootstrap` is retained as a compatibility wrapper for `dot bootstrap`. Every replacement is moved to `~/.dotfiles-backup/<timestamp>/` before a link or allowlisted copy is made. No command uninstalls applications, removes packages, cleans Homebrew, or changes macOS defaults unless explicitly requested.

## Commands

| Command | Purpose |
| --- | --- |
| `dot bootstrap` | Preflight, Homebrew bundle, mise runtimes, links, and plugin restoration. |
| `dot link` | Link directly managed files with recoverable backups. |
| `dot packages` | Apply [`Brewfile`](Brewfile). |
| `dot runtimes` | Install the exact versions in [`mise.toml`](mise.toml). |
| `dot plugins` | Restore Cursor extensions and Codex plugins from manifests. |
| `dot sync --from-machine` | Capture only allowlisted Rider and generated Codex settings into the repository. |
| `dot sync --to-machine` | Restore only allowlisted Rider and generated Codex settings, with backups. |
| `dot macos` | Preview current and desired macOS defaults. Add `--yes` to apply. |
| `dot doctor` | Report package, link, runtime, and authentication drift. |
| `dot update` | Fast-forward the clone and safely reapply managed state. |

All commands accept `--dry-run`; it never writes files or invokes installers. Commands that install, synchronize, update, or apply macOS changes require an interactive confirmation unless `--yes` is supplied.

## Toolchain

The Brewfile contains the current command-line tools, Colima plus Docker CLI/Buildx/Compose, and the developer desktop suite. Docker Desktop is intentionally not installed. Xcode is installed through `mas` with App Store ID `497799835`.

`mise.toml` pins Node 26.5.0, Python 3.14.6, Go 1.26.2, and .NET SDK 10.0.203. The Zsh setup activates mise without removing pre-existing system or Homebrew runtimes.

Hermes and Dia are intentionally manual installs: no maintained Homebrew cask was selected for either. Install them from their official distributions, then rerun `dot doctor`.

## Managed preferences and privacy boundary

Tracked configuration covers Zsh, Git, generic SSH defaults, Ghostty, Zed, Cursor settings/snippets, safe Rider editor preferences, GitHub CLI defaults, global Codex instructions, and sanitized Codex defaults. Machine-specific overrides remain local:

- `~/.zshrc.local` for private shell environment values.
- `~/.gitconfig.local` for identity.
- `~/.ssh/config.local` for hosts and identities.
- `~/.config/gh/hosts.yml` for GitHub authentication.

Codex authentication stays in the macOS Keychain. The repository excludes `auth.json`, histories, memories, caches, project trust, connector state, MCP environment values, browser profiles, workspace storage, recent projects, chat histories, OAuth data, tokens, cookies, private keys, models, and vault contents. The declared Codex plugin state is represented by `manifest/codex-plugins.tsv` and `config/codex/config.toml`.

Run `./script/check` before committing. It validates manifests, pins, managed sources, shell syntax, 224 documented keybindings across 13 files, and runs gitleaks when installed. CI runs the same checks plus temporary-home link idempotency and every non-mutating management preview. Enable GitHub Secret Scanning and Push Protection in the repository security settings if the repository/account supports them.

## macOS defaults

`dot macos` is deliberately separate from bootstrap. It previews the current value beside each desired value; `dot macos --yes` first exports affected defaults domains to the backup directory, then applies only the reviewed Dock, Finder, keyboard/text, and `.DS_Store` preferences. It does not change privacy permissions, security policy, FileVault, gestures, default apps, or screenshot location. Finder and Dock restart only after an explicit apply.

## Application keybindings

Browse the complete catalog in [`keybindings/`](keybindings/README.md). Each application has a standalone Markdown file that can be searched from the terminal or opened directly in an editor.

```bash
rg -i "rename|terminal|search" ~/.config/keybindings
```
