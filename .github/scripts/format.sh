#!/bin/bash
#
# Formats every Swift source file with Apple's `swift format`, or checks that
# they are already formatted. Run it from the repository root:
#
#     .github/scripts/format.sh            # rewrite the files
#     .github/scripts/format.sh --check    # report, change nothing
#
# `--check` exits 0 when the tree is formatted and 1 when it is not. On GitHub
# Actions it also writes a short report to the job summary and an annotation to
# the log.

set -uo pipefail

# `swift format` has no `excluded` setting, and a `.swift-format-ignore` file
# does nothing in the 6.3.0 that ships with Xcode 26.5. So naming the roots is
# the only thing that keeps the formatter out of `.build-shared`, out of each
# package's own `.build`, and out of a second worktree. A bare `--recursive .`
# would rewrite third-party dependency source in place.
#
# These are the same roots `.swiftlint.yml` lists under `included`.
ROOTS=(
    Packages
    SwiftLeeds
    SwiftLeedsAppClip
    SwiftLeedsPackage
    SwiftLeedsTests
    SwiftLeedsUITests
    SwiftLeedsWidget
)

work=${RUNNER_TEMP:-$(mktemp -d)}
summary=${GITHUB_STEP_SUMMARY:-/dev/null}
log="$work/format-errors.log"
: > "$log"

fatal () {
    echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $1" >> "$log"
    if [ -n "${GITHUB_ACTIONS:-}" ]; then
        echo "::error::$1"
    else
        echo "error: $1" >&2
        echo "error: also recorded in $log" >&2
    fi
}

if [ ! -f .swift-format ]; then
    fatal "No .swift-format in $(pwd). Run this from the repository root."
    exit 1
fi

# A `rules` block replaces the defaults rather than merging with them, and
# `swift format` drops a key it does not recognise without saying so. One typo
# among the 43 rule names therefore switches that rule off for good, and a typo
# in `lineLength` or `indentation` silently restores 100 columns and 2 spaces.
# Dumping the parsed configuration back out and diffing it against the file
# catches both: a dropped key shows as a difference, and the value the tool fell
# back to is printed beside it.
echo "Checking .swift-format round-trips through swift format"

if ! swift format dump-configuration --effective --configuration .swift-format \
    > "$work/effective.json"
then
    fatal ".swift-format is not valid JSON, or swift format refused it"
    exit 1
fi

if ! diff -u .swift-format "$work/effective.json" > "$work/config.diff"; then
    fatal ".swift-format holds a key swift format does not recognise, so it was ignored"
    cat "$work/config.diff"
    {
        echo "### 🧩 Formatting configuration"
        echo
        echo "\`.swift-format\` holds a key that \`swift format\` does not recognise, so the"
        echo "tool ignored it and used its own default instead. Check the spelling."
        echo
        echo "The left side is the file. The right side is what the tool read."
        echo
        echo '```diff'
        cat "$work/config.diff"
        echo '```'
    } >> "$summary"
    exit 1
fi

if [ "${1:-}" != "--check" ]; then
    echo "Formatting ${#ROOTS[@]} roots in place"
    if ! swift format format --in-place --recursive --parallel \
        --configuration .swift-format "${ROOTS[@]}"
    then
        fatal "swift format could not rewrite every file"
        exit 1
    fi
    echo "Done. Review the changes with git diff."
    exit 0
fi

echo "Linting formatting over ${#ROOTS[@]} roots"

status=0
swift format lint --strict --recursive --parallel \
    --configuration .swift-format "${ROOTS[@]}" \
    > "$work/findings.log" 2>&1 || status=$?
cat "$work/findings.log"

if [ "$status" -eq 0 ]; then
    {
        echo "### ✅ Formatting"
        echo
        echo "Every Swift file is formatted."
    } >> "$summary"
    echo "Every Swift file is formatted"
    exit 0
fi

# Each finding reads `path:line:column: error: [Rule] message`, so the first
# field is the file. A reviewer needs the file count and the command that fixes
# it; the findings themselves are already in the log above.
cut -d: -f1 < "$work/findings.log" | sort -u > "$work/files.txt"
count=$(wc -l < "$work/files.txt" | tr -d ' ')

fatal "$count file(s) are not formatted"
{
    echo "### 🎨 Formatting"
    echo
    echo "**$count file(s) need formatting.**"
    echo
    echo "Fix every one of them with this command, then commit the result:"
    echo
    echo '```sh'
    echo ".github/scripts/format.sh"
    echo '```'
    echo
    echo "<details><summary>The files</summary>"
    echo
    while IFS= read -r file; do
        echo "- \`$file\`"
    done < "$work/files.txt"
    echo
    echo "</details>"
    echo
    echo "<details><summary>What the formatter found</summary>"
    echo
    echo '```'
    cat "$work/findings.log"
    echo '```'
    echo
    echo "</details>"
} >> "$summary"

exit 1
