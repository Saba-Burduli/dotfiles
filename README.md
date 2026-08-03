# dotfiles

Portable macOS development preferences, shell configuration, Git defaults, package declarations, and application keybindings.

## What's included

```text
.
├── git/          Git defaults, aliases, and global ignores
├── keybindings/  224 shortcuts for 13 applications and tools
├── script/       Safe, repeatable setup commands
├── zsh/          Shell preferences and aliases
├── Brewfile      Developer command-line packages
└── .editorconfig Shared editor formatting defaults
```

The repository is organized by topic. Files ending in `.symlink` are linked into the home directory by the bootstrap script. Existing files are moved to a timestamped backup directory before any link is created.

## Install

Clone the repository and preview the changes:

```bash
git clone https://github.com/Saba-Burduli/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap --dry-run
```

Apply the links after reviewing the preview:

```bash
script/bootstrap
```

The script links:

- `git/gitconfig.symlink` to `~/.gitconfig`
- `git/gitignore.symlink` to `~/.gitignore_global`
- `zsh/zshrc.symlink` to `~/.zshrc`
- `keybindings/` to `~/.config/keybindings`

## Personal settings and secrets

Machine-specific Git identity belongs in `~/.gitconfig.local`, outside the repository:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
```

Machine-specific shell settings and secrets belong in `~/.zshrc.local`. Both `*.local` and `.env*` files are ignored so credentials are not accidentally committed.

## Packages

Review [`Brewfile`](Brewfile), then install its packages explicitly:

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

Package installation is intentionally separate from bootstrap.

## Application keybindings

Browse the complete catalog in [`keybindings/`](keybindings/README.md). Each application has a standalone Markdown file that can be searched from the terminal or opened directly in an editor.

```bash
rg -i "rename|terminal|search" ~/.config/keybindings
```
