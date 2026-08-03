#!/usr/bin/env python3
"""Validate the generated Keytome shortcut catalog."""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = ROOT / "data" / "shortcuts.json"
MARKDOWN_PATH = ROOT / "SHORTCUTS.md"


def main() -> None:
    catalog = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    shortcuts = catalog["shortcuts"]

    assert catalog["filter"] == "kind == shortcut"
    assert catalog["totalShortcuts"] == len(shortcuts)
    assert re.fullmatch(r"[0-9a-f]{40}", catalog["sourceRevision"])
    assert all(item["kind"] == "shortcut" for item in shortcuts)

    ids = [item["id"] for item in shortcuts]
    assert len(ids) == len(set(ids)), "shortcut IDs must be unique"

    actual_counts = Counter(item["category"] for item in shortcuts)
    declared_counts = {
        item["category"]: item["count"] for item in catalog["categories"]
    }
    assert declared_counts == dict(actual_counts)

    markdown = MARKDOWN_PATH.read_text(encoding="utf-8")
    assert catalog["sourceRevision"] in markdown
    assert f"**{len(shortcuts)} shortcuts**" in markdown

    print(f"Validated {len(shortcuts)} shortcuts across {len(actual_counts)} categories.")


if __name__ == "__main__":
    main()
