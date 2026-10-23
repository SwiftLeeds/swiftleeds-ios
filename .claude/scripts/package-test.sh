#!/bin/bash
#
# Runs one package's tests against the repository's shared scratch path.
#
# Run from inside a package, `swift test` writes Packages/<Folder>/<Name>/.build,
# which holds a full copy of every dependency checkout and build product. One
# shared path holds one copy.
#
# A passing run prints only its summary lines, so no caller has to pipe this to
# tail. A failing run prints everything, so nothing is hidden.
#
# Usage: .claude/scripts/package-test.sh <PackageName> [extra swift test args]
#
# <PackageName> is the folder name only, found at Packages/<Folder>/<PackageName>.

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: $(basename "$0") <PackageName> [extra swift test args]" >&2
    exit 2
fi

# In a worktree this is the worktree, so each one keeps its own scratch path
# and two of them never contend for the same SwiftPM lock.
repo=$(git rev-parse --show-toplevel)
package="$1"
shift

# A package sits at Packages/<Folder>/<Name>. Exactly one must match, so a name
# used in two folders fails instead of picking one.
matches=()
for manifest in "$repo"/Packages/*/"$package"/Package.swift; do
    [ -f "$manifest" ] && matches+=("$(dirname "$manifest")")
done

if [ ${#matches[@]} -ne 1 ]; then
    echo "Expected exactly one package named $package at Packages/*/$package, found ${#matches[@]}" >&2
    exit 1
fi
package_path=${matches[0]}

log=$(mktemp -t package-test)
trap 'rm -f "$log"' EXIT

# --package-path rather than cd, so the caller's working directory is untouched.
#
# The import check judges only files that recompile, so an up-to-date build
# passes unchecked.
status=0
swift test \
    --package-path "$package_path" \
    --scratch-path "$repo/.build-shared" \
    --explicit-target-dependency-import-check error \
    "$@" >"$log" 2>&1 || status=$?

if [ "$status" -eq 0 ]; then
    # One summary line from Swift Testing, one from XCTest.
    sed -n -e '/Test run with /p' -e '/Executed .* test/p' "$log"
else
    cat "$log"
fi

exit "$status"

