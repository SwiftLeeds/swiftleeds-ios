#!/usr/bin/env python3
"""Checks the SnapshotTests scheme lists every snapshot test target.

The simulator job runs one xcodebuild call against that scheme, so a target the
scheme does not name never runs on iOS. It would still compile on macOS and do
nothing there, which is the same silent gap the "snapshot tests live in a
snapshot target" check exists to close.

Run locally: python3 .github/scripts/check-snapshot-scheme.py
"""
import re
import sys
from pathlib import Path

SCHEME = Path("SwiftLeeds.xcodeproj/xcshareddata/xcschemes/SnapshotTests.xcscheme")

# A test target is a folder under a package's Tests folder. SwiftPM names the
# target after the folder, so the folder name is the target name.
targets = {path.name for path in Path("Packages").glob("*/Tests/*SnapshotTests") if path.is_dir()}

# Zero targets means the layout moved, not that the repository is clean.
if not targets:
    print("::error::Found no *SnapshotTests target under Packages/, so this check is broken")
    sys.exit(1)

if not SCHEME.is_file():
    print(f"::error::{SCHEME} is missing, so the simulator job has no scheme to run")
    sys.exit(1)

listed = set(re.findall(r'BlueprintName = "(\w+SnapshotTests)"', SCHEME.read_text()))

missing = sorted(targets - listed)
extra = sorted(listed - targets)

if missing:
    print(f"::error::{SCHEME} does not list these snapshot targets, so they never run on iOS: {', '.join(missing)}")
if extra:
    print(f"::error::{SCHEME} lists these targets, which do not exist: {', '.join(extra)}")

if missing or extra:
    sys.exit(1)

print(f"{SCHEME}: lists all {len(targets)} snapshot targets")
