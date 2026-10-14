#!/bin/bash
#
# Runs SwiftLint's analyzer rules (unused_import, capture_variable) over one
# scope of the repository, using the compiler log of a build that compiled it.
# Run it from anywhere; it moves to the repository root itself:
#
#     .github/scripts/analyze.sh <scope> <min-files> <log>...
#
#     scope      app, tests or snapshots (below)
#     min-files  fail when a run analyses fewer files than this
#     log        a raw build log. SwiftPM prints compile commands only with -v,
#                so a `swift build` or `swift test` log needs it. Several logs
#                are joined.
#
# Exits 0 when every rule is clean, and 1 when a rule reports a violation,
# SwiftLint fails, or too few files were analysed. On GitHub Actions the failure
# is also an annotation.
#
# Each file is judged by one log only, so the verdict does not depend on how
# many builds happen to mention it:
#
#     app        Packages/*/Sources, except the *TestSupport targets, and the
#                app, App Clip, widget and SwiftLeedsPackage folders
#                                            the iOS app Release build
#     tests      Packages/*/Tests, except the *SnapshotTests folders, and the
#                *TestSupport targets, which no app links
#                                            the macOS package build
#     snapshots  Packages/*/Tests/*SnapshotTests
#                                            the iOS snapshot-test build
#
# A source file compiles differently on each platform, and an import is used or
# unused depending on which `#if` branch compiled. A file judged by two logs could
# pass one and fail the other, so the build that matches how the file ships wins.
#
# Traps this script guards, each measured on SwiftLint 0.65.1:
#
#   * `analyze` ignores a path argument. The config's `included:` decides what is
#     analysed, so the script writes a config of its own per scope. It cannot use
#     `parent_config`, because a child's `included:` is merged with the parent's
#     and the scope would then cover everything. The copy sits in the repository
#     root, because `included:` resolves relative to the config's own folder, and
#     a trap deletes it.
#   * All rules in one run segfaulted on the macOS log, so each rule gets a run.
#   * A log only works while the build products it names exist. SwiftLint then
#     analyses 0 files and still exits 0, so "Done analyzing! ... in 0 files" is
#     a failure here, as is any count below <min-files>.
#   * A run reads the whole log whatever the scope, so the macOS log takes many
#     minutes. The scope config keeps the files analysed to the scope's own.

set -uo pipefail

if [ "$#" -lt 3 ]; then
    echo "usage: analyze.sh <app|tests|snapshots> <min-files> <log>..." >&2
    exit 2
fi

scope=$1
min_files=$2
shift 2

cd "$(dirname "$0")/../.." || exit 1

work=${RUNNER_TEMP:-$(mktemp -d)}
errors="$work/analyze-errors.log"
: > "$errors"

# Failures go to a log file with a timestamp, so one can be debugged after the
# terminal has scrolled away. Progress lines never go there.
fatal () {
    echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $1" >> "$errors"
    if [ -n "${GITHUB_ACTIONS:-}" ]; then
        echo "::error::$1"
    else
        echo "error: $1" >&2
        echo "error: also recorded in $errors" >&2
    fi
}

# The folders the scope covers, and any folder to leave out of them. Globs, as
# SwiftLint's `included:` and `excluded:` take them.
case "$scope" in
    app)
        included="Packages/*/Sources SwiftLeeds SwiftLeedsAppClip SwiftLeedsWidget SwiftLeedsPackage"
        also_excluded="Packages/*/Sources/*TestSupport"
        ;;
    tests)
        included="Packages/*/Tests Packages/*/Sources/*TestSupport"
        also_excluded="Packages/*/Tests/*SnapshotTests"
        ;;
    snapshots)
        included="Packages/*/Tests/*SnapshotTests"
        also_excluded=""
        ;;
    *)
        fatal "Unknown scope '$scope'. Use app, tests or snapshots."
        exit 2
        ;;
esac

case "$min_files" in
    ''|*[!0-9]*)
        fatal "<min-files> must be a whole number, not '$min_files'."
        exit 2
        ;;
esac

if [ ! -f .swiftlint.yml ]; then
    fatal "No .swiftlint.yml in $(pwd). Run this from the repository root."
    exit 1
fi

for log in "$@"; do
    if [ ! -s "$log" ]; then
        fatal "The build log '$log' is missing or empty."
        exit 1
    fi
done

joined="$work/analyze-$scope.log"
cat "$@" > "$joined"

# Keeps every setting of .swiftlint.yml, and swaps its `included:` list for the
# scope's. The `included:` block is the lines up to the next top-level key.
config=".swiftlint-analyze-$scope.yml"
trap 'rm -f "$config"' EXIT
awk -v included="$included" -v also_excluded="$also_excluded" '
    function emit(list,    n, parts, i) {
        n = split(list, parts, " ")
        for (i = 1; i <= n; i++) print "  - \"" parts[i] "\""
    }
    skipping && /^[[:space:]]*-/ { next }
    { skipping = 0 }
    /^included:/ { print; emit(included); skipping = 1; next }
    /^excluded:/ { print; emit(also_excluded); next }
    { print }
' .swiftlint.yml > "$config"

echo "Analysing the $scope scope with $# log(s), at least $min_files file(s) expected"

status=0
for rule in unused_import capture_variable; do
    echo "Running $rule"
    started=$(date +%s)
    out="$work/analyze-$scope-$rule.out"
    err="$work/analyze-$scope-$rule.err"
    run_status=0
    swiftlint analyze --strict --only-rule "$rule" \
        --compiler-log-path "$joined" --config "$config" \
        > "$out" 2> "$err" || run_status=$?
    seconds=$(( $(date +%s) - started ))

    # The last line reads: Done analyzing! Found N violations, M serious in F files.
    # The one-line-per-file progress above it stays in the file, out of the log.
    summary=$(tail -n 1 "$err")
    files=$(sed -n 's/^Done analyzing!.* in \([0-9][0-9]*\) files\{0,1\}\.$/\1/p' <<< "$summary")
    cat "$out"
    echo "$rule: ${files:-unknown} file(s) analysed in ${seconds}s. $summary"

    if [ -z "$files" ]; then
        tail -n 20 "$err" >&2
        fatal "$rule: SwiftLint did not finish (exit $run_status), so no verdict."
        status=1
    elif [ "$files" -lt "$min_files" ]; then
        fatal "$rule: analysed $files file(s), below the $min_files expected. A build product the log names may be gone."
        status=1
    elif [ "$run_status" -ne 0 ]; then
        fatal "$rule: SwiftLint reported violations in the $scope scope (exit $run_status)."
        status=1
    fi
done

if [ "$status" -eq 0 ]; then
    echo "The $scope scope is clean"
fi
exit "$status"
