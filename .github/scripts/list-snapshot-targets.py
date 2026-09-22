#!/usr/bin/env python3
"""Prints each snapshot test target and the package that holds it.

One line per target: "<target> <package path>".

The simulator job used `swift package describe` on all 16 packages to find the
seven that have snapshot tests, which cost 26s of a 473s step. The scheme
already names them, and a lint check fails when the scheme and the manifests
disagree, so reading the scheme costs nothing and cannot drift unnoticed.

Run locally: python3 .github/scripts/list-snapshot-targets.py
"""
import sys
import xml.etree.ElementTree as ElementTree
from pathlib import Path

SCHEME = Path("SwiftLeeds.xcodeproj/xcshareddata/xcschemes/SnapshotTests.xcscheme")

if not SCHEME.is_file():
    print(f"::error::{SCHEME} is missing, so the simulator job has no targets to run", file=sys.stderr)
    sys.exit(1)

lines = []
for testable in ElementTree.parse(SCHEME).findall("./TestAction/Testables/TestableReference"):
    # A skipped testable does not run, so the job must not select it.
    if testable.get("skipped") != "NO":
        continue
    for reference in testable.findall("./BuildableReference"):
        target = reference.get("BlueprintName")
        # "container:Packages/AboutUI" names the package folder.
        container = reference.get("ReferencedContainer", "")
        package = container.removeprefix("container:")
        if not target or not package:
            print(f"::error::{SCHEME} has a testable with no target or no container", file=sys.stderr)
            sys.exit(1)
        lines.append(f"{target} {package}")

# Zero targets means the scheme was emptied, not that the repository is clean.
if not lines:
    print(f"::error::{SCHEME} runs no snapshot target", file=sys.stderr)
    sys.exit(1)

print("\n".join(sorted(lines)))
