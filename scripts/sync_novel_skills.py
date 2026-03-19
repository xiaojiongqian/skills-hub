#!/usr/bin/env python3
"""
Synchronize shared novel-system references from the canonical source skill
into each novel sub-skill.

The canonical source lives at:
    skills/novel-orchestrator-main/references/novel-system/

Targets receive a generated copy at:
    skills/<novel-sub-skill>/references/novel-system/

The target tree is replaced wholesale on each sync so files removed from the
canonical source are also removed from generated copies.
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = REPO_ROOT / "skills" / "novel-orchestrator-main" / "references" / "novel-system"
TARGET_SKILLS = [
    "novel-bible-manager",
    "novel-plot-architect",
    "novel-scene-dramatizer",
    "novel-dialogue-editor",
    "novel-continuity-auditor",
    "novel-chapter-summarizer",
]


def compare_trees(left: Path, right: Path) -> list[str]:
    diffs: list[str] = []

    if not right.exists():
        return [f"missing target tree: {right.relative_to(REPO_ROOT)}"]

    left_entries = {path.name: path for path in left.iterdir()}
    right_entries = {path.name: path for path in right.iterdir()}

    for name in sorted(left_entries.keys() - right_entries.keys()):
        diffs.append(f"missing in target: {(left / name).relative_to(REPO_ROOT)}")

    for name in sorted(right_entries.keys() - left_entries.keys()):
        diffs.append(f"extra in target: {(right / name).relative_to(REPO_ROOT)}")

    for name in sorted(left_entries.keys() & right_entries.keys()):
        left_path = left_entries[name]
        right_path = right_entries[name]

        if left_path.is_dir() and right_path.is_dir():
            diffs.extend(compare_trees(left_path, right_path))
            continue

        if left_path.is_file() and right_path.is_file():
            if left_path.read_bytes() != right_path.read_bytes():
                diffs.append(f"content differs: {right_path.relative_to(REPO_ROOT)}")
            continue

        diffs.append(f"type differs: {right_path.relative_to(REPO_ROOT)}")

    return diffs


def write_target(source: Path, target: Path) -> None:
    """Replace the generated target tree with the canonical source tree."""
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        shutil.rmtree(target)
    shutil.copytree(source, target)


def main() -> int:
    parser = argparse.ArgumentParser(description="Sync shared novel references into sub-skills.")
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check whether targets match the canonical source without modifying files.",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Write canonical contents into target skills.",
    )
    args = parser.parse_args()

    mode_write = args.write or not args.check

    if not SOURCE_DIR.exists():
        print(f"[ERROR] Canonical source not found: {SOURCE_DIR}", file=sys.stderr)
        return 1

    failures: list[str] = []
    for skill_name in TARGET_SKILLS:
        target = REPO_ROOT / "skills" / skill_name / "references" / "novel-system"
        if mode_write:
            write_target(SOURCE_DIR, target)
            print(f"[SYNC] {skill_name} <= {SOURCE_DIR.relative_to(REPO_ROOT)}")
        diffs = compare_trees(SOURCE_DIR, target)
        if diffs:
            failures.append(f"{skill_name}:")
            failures.extend(f"  - {item}" for item in diffs)

    if failures:
        print("[DRIFT] Novel skill references are out of sync:", file=sys.stderr)
        print("\n".join(failures), file=sys.stderr)
        return 1

    print("[OK] Novel skill references are in sync.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
