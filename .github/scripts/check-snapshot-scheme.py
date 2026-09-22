#!/usr/bin/env python3
"""Checks the SnapshotTests scheme runs every snapshot test target.

The simulator job runs one xcodebuild call against that scheme, so a target the
scheme does not run never runs on iOS. It would still compile on macOS and do
nothing there, which is the same silent gap the "snapshot tests live in a
snapshot target" check exists to close.

Run locally: python3 .github/scripts/check-snapshot-scheme.py
"""
import re
import sys
import xml.etree.ElementTree as ElementTree
from pathlib import Path

SCHEME = Path("SwiftLeeds.xcodeproj/xcshareddata/xcschemes/SnapshotTests.xcscheme")

# The manifest is where a target is declared, which is also where the job's
# `swift package describe` reads it from. A folder name would disagree with
# the job the moment a target declared its own path.
declaration = re.compile(r'\.testTarget\(\s*name:\s*"(\w+SnapshotTests)"')
targets = {
    name
    for manifest in Path("Packages").glob("*/Package.swift")
    for name in declaration.findall(manifest.read_text())
}

# Zero targets means the manifests moved, not that the repository is clean.
if not targets:
    print("::error::Found no *SnapshotTests target in Packages/*/Package.swift, so this check is broken")
    sys.exit(1)

if not SCHEME.is_file():
    print(f"::error::{SCHEME} is missing, so the simulator job has no scheme to run")
    sys.exit(1)

# Only a testable that is not skipped runs. A name anywhere else in the file,
# such as under BuildActionEntries, proves nothing about what runs.
listed = {
    reference.get("BlueprintName")
    for testable in ElementTree.parse(SCHEME).findall("./TestAction/Testables/TestableReference")
    if testable.get("skipped") == "NO"
    for reference in testable.findall("./BuildableReference")
}

missing = sorted(targets - listed)
extra = sorted(listed - targets)

if missing:
    print(f"::error::{SCHEME} does not run these snapshot targets, so they never run on iOS: {', '.join(missing)}")
if extra:
    print(f"::error::{SCHEME} runs these targets, which no package declares: {', '.join(extra)}")

if missing or extra:
    sys.exit(1)

print(f"{SCHEME}: runs all {len(targets)} snapshot targets")
