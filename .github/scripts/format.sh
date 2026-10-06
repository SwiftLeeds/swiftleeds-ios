#!/bin/bash
#
# Formats every Swift source file git tracks with Apple's `swift format`, or
# checks that they are already formatted. Run it from the repository root:
#
#     .github/scripts/format.sh            # rewrite the files
#     .github/scripts/format.sh --check    # report, change nothing
#
# `--check` exits 0 when the tree is formatted and 1 when it is not. On GitHub
# Actions it also writes a short report to the job summary and an annotation to
# the log.
#
# A new file is covered once it is staged, because staging puts it in the index
# and that is what git lists. The pre-commit hook is the gate that catches it.

set -uo pipefail

# `swift format` has no `excluded` setting, and a `.swift-format-ignore` file
# does nothing in the 6.3.0 that ships with Xcode 26.5. The paths it is given are
# the only control there is, and a bare `--recursive .` would rewrite third-party
# dependency source in place.
#
# So ask git for the files instead of naming directories. Build output is
# ignored, so it can never be reached: not `.build-shared`, not a package's own
# `.build`, not a stray `dd` inside a package, not a worktree. A directory list
# cannot promise that, because build output sits inside the source directories
# rather than beside them.
#
# This covers every Swift file the repository tracks, so a new directory needs no
# change here.
swift_files () {
    git ls-files -z '*.swift'
}

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

count=$(git ls-files '*.swift' | wc -l | tr -d ' ')
if [ "$count" -eq 0 ]; then
    fatal "git tracks no Swift files here, so this check is broken"
    exit 1
fi

if [ "${1:-}" != "--check" ]; then
    echo "Formatting $count tracked Swift files in place"
    if ! swift_files | xargs -0 swift format format --in-place --parallel \
        --configuration .swift-format
    then
        fatal "swift format could not rewrite every file"
        exit 1
    fi
    echo "Done. Review the changes with git diff."
    exit 0
fi

echo "Linting $count tracked Swift files"

status=0
swift_files | xargs -0 swift format lint --strict --parallel \
    --configuration .swift-format \
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
