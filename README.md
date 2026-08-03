# dotfiles

Portable reference material extracted from [Keytome for macOS](https://github.com/Saba-Burduli/keytome-macos).

## Keytome summary

Keytome is a native Swift 6 macOS app for browsing keyboard shortcuts and command references entirely offline. Its bundled packs cover macOS, browsers, terminals, editors, AI coding tools, note-taking software, and game-development tools. The app uses typed seed data, keyboard-first navigation, search, copy-to-clipboard actions, confidence labels, and per-pack visual themes. It targets macOS 14 or newer and ships without accounts, analytics, a backend, or a network dependency.

## Filtered shortcut catalog

This repository deliberately contains only Keytome records whose type is `shortcut`. Shell commands, CLI invocations, slash commands, configuration keys, and other records whose type is `command` are excluded.

- [`SHORTCUTS.md`](SHORTCUTS.md) is the human-readable catalog grouped by application or tool.
- [`data/shortcuts.json`](data/shortcuts.json) is the machine-readable catalog with IDs, descriptions, tags, and confidence levels.
- [`scripts/export_keytome_shortcuts.swift`](scripts/export_keytome_shortcuts.swift) regenerates both catalogs from a local Keytome checkout.
- [`scripts/verify_shortcuts.py`](scripts/verify_shortcuts.py) validates the generated data and Markdown summary.

## Regenerate

From this repository, with Keytome checked out next to it:

```bash
KEYTOME_REPO=../keytome-macos
SOURCE_REVISION="$(git -C "$KEYTOME_REPO" rev-parse HEAD)"

swiftc \
  "$KEYTOME_REPO/Sources/Keytome/Models/ReferenceCategory.swift" \
  "$KEYTOME_REPO/Sources/Keytome/Models/ReferenceItem.swift" \
  "$KEYTOME_REPO/Sources/Keytome/Data/SeedData.swift" \
  "$KEYTOME_REPO/Sources/Keytome/Data/ExtendedSeedData.swift" \
  scripts/export_keytome_shortcuts.swift \
  -o /tmp/keytome-shortcut-export

/tmp/keytome-shortcut-export \
  --source-revision "$SOURCE_REVISION" \
  --json data/shortcuts.json \
  --markdown SHORTCUTS.md

python3 scripts/verify_shortcuts.py
```

The generated files are deterministic for a given Keytome revision.

## Source and rights

The catalog records originate in Keytome and retain their source revision in each generated artifact. See [`NOTICE`](NOTICE) for the applicable rights notice.
