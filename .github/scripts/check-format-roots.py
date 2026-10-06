"""Checks that `swift format` and SwiftLint read the same source roots.

`swift format` has no `excluded` setting, so `.github/scripts/format.sh` names
the directories it walks in a `ROOTS` array. `.swiftlint.yml` names the same
ground under `included`. Nothing links the two, so a new top-level source
directory can reach one list and not the other. It would then be linted and
never formatted, or formatted and never linted, and both jobs would stay green.

The comparison is by top-level path component, because SwiftLint reaches into a
package (`Packages/*/Sources`) where the formatter takes the whole tree
(`Packages`). Reduce both to their first component and the two must match.

Reads two text files. No Xcode, no toolchain, no compiler.
"""

import re
import sys

FORMAT_SCRIPT = ".github/scripts/format.sh"
SWIFTLINT_CONFIG = ".swiftlint.yml"

ROOTS_BLOCK = re.compile(r"^ROOTS=\(\s*$(.*?)^\)\s*$", re.MULTILINE | re.DOTALL)


def format_roots() -> set[str]:
    """The top-level directories format.sh walks."""
    with open(FORMAT_SCRIPT, encoding="utf-8") as script:
        match = ROOTS_BLOCK.search(script.read())
    if match is None:
        print(f"::error::{FORMAT_SCRIPT} has no ROOTS=( ... ) array, so this check is broken")
        sys.exit(1)
    entries = {line.strip() for line in match.group(1).splitlines() if line.strip()}
    if not entries:
        print(f"::error::{FORMAT_SCRIPT} declares an empty ROOTS array")
        sys.exit(1)
    return entries


def swiftlint_roots() -> set[str]:
    """The top-level components of every path under SwiftLint's `included`."""
    entries: set[str] = set()
    inside = False
    with open(SWIFTLINT_CONFIG, encoding="utf-8") as config:
        for line in config:
            if line.startswith("included:"):
                inside = True
                continue
            if inside:
                # A comment or a blank line sits inside the list. Any other
                # unindented line starts the next key.
                if line.strip().startswith("#") or not line.strip():
                    continue
                if not line.startswith((" ", "\t", "-")):
                    break
                stripped = line.strip()
                if not stripped.startswith("- "):
                    break
                entries.add(stripped[2:].strip().strip('"').split("/")[0])
    if not entries:
        print(f"::error::{SWIFTLINT_CONFIG} has no `included` paths, so this check is broken")
        sys.exit(1)
    return entries


formatted = format_roots()
linted = swiftlint_roots()

print(f"{FORMAT_SCRIPT} walks {len(formatted)} root(s): {', '.join(sorted(formatted))}")
print(f"{SWIFTLINT_CONFIG} lints {len(linted)} root(s): {', '.join(sorted(linted))}")

unformatted = linted - formatted
unlinted = formatted - linted

if unformatted:
    print(
        f"::error::{SWIFTLINT_CONFIG} lints these roots, which {FORMAT_SCRIPT} "
        f"never formats: {', '.join(sorted(unformatted))}"
    )
if unlinted:
    print(
        f"::error::{FORMAT_SCRIPT} formats these roots, which {SWIFTLINT_CONFIG} "
        f"never lints: {', '.join(sorted(unlinted))}"
    )
if unformatted or unlinted:
    sys.exit(1)

print("Both tools read the same roots")
