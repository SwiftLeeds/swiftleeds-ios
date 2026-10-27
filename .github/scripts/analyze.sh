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
# SwiftLint fails, or too few files were analysed.
#
#     .github/scripts/analyze.sh scopes
#
# Runs no SwiftLint. Checks that exactly one scope covers each Swift file git
# tracks, except the package manifests. Exits 1 when a file has no scope, which
# the analyser would never read, or more than one.
#
# On GitHub Actions a failure in either mode is also an annotation.
#
# Each file is judged by one log only, so the verdict does not depend on how
# many builds happen to mention it:
#
#     app        Packages/*/*/Sources, except the *TestSupport targets, and the
#                app, App Clip, widget and SwiftLeedsPackage folders
#                                            the iOS app Release build
#     tests      Packages/*/*/Tests, except the *SnapshotTests folders, and the
#                *TestSupport targets, which no app links
#                                            the macOS package build
#     snapshots  Packages/*/*/Tests/*SnapshotTests
#                                            the iOS snapshot-test build
#
# A package sits at Packages/<Folder>/<Name>. The globs go into a config file for
# SwiftLint, never through the shell's own expansion, and SwiftLint ignores a
# glob that matches nothing. The scopes check matches them as regexes.
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

mode=analyze
if [ "$#" -eq 1 ] && [ "$1" = scopes ]; then
    mode=scopes
elif [ "$#" -lt 3 ]; then
    echo "usage: analyze.sh <app|tests|snapshots> <min-files> <log>..." >&2
    echo "       analyze.sh scopes" >&2
    exit 2
fi

if [ "$mode" = analyze ]; then
    scope=$1
    min_files=$2
    shift 2

    # A relative log path means relative to where the caller stands, so resolve
    # each one before moving to the repository root.
    logs=()
    for log in "$@"; do
        case "$log" in
            /*) logs+=("$log") ;;
            *) logs+=("$PWD/$log") ;;
        esac
    done
    set -- "${logs[@]}"
fi

cd "$(dirname "$0")/../.." || exit 1

# On Actions the runner cleans RUNNER_TEMP itself. Locally the script makes a
# folder of its own and removes it on a clean run. A failed run keeps it, because
# the error log inside is what the failure message points at.
work=${RUNNER_TEMP:-}
made_work=""
if [ -z "$work" ]; then
    work=$(mktemp -d)
    made_work=$work
fi
config=""
cleanup () {
    local exit_status=$?
    [ -z "$config" ] || rm -f "$config"
    if [ -n "$made_work" ] && [ "$exit_status" -eq 0 ]; then
        rm -rf "$made_work"
    fi
}
trap cleanup EXIT

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

# Sets `included` and `also_excluded` to the folders a scope covers, and any
# folder to leave out of them. Globs, as SwiftLint's `included:` and `excluded:`
# take them. Call it directly, not in `$(...)`, or the variables are lost.
scope_globs () {
    case "$1" in
        app)
            included="Packages/*/*/Sources SwiftLeeds SwiftLeedsAppClip SwiftLeedsWidget SwiftLeedsPackage"
            also_excluded="Packages/*/*/Sources/*TestSupport"
            ;;
        tests)
            included="Packages/*/*/Tests Packages/*/*/Sources/*TestSupport"
            also_excluded="Packages/*/*/Tests/*SnapshotTests"
            ;;
        snapshots)
            included="Packages/*/*/Tests/*SnapshotTests"
            also_excluded=""
            ;;
        *)
            fatal "Unknown scope '$1'. Use app, tests or snapshots."
            exit 2
            ;;
    esac
}

# Sets `regex` to match a path inside the folder a glob names. `*` stops at `/`,
# as it does in SwiftLint, so one `*` never spans two folder levels. Only `.` is
# escaped, so a glob with `+`, `(` or `[` would need more.
glob_regex () {
    local glob=${1//./\\.}
    regex="^${glob//\*/[^/]*}/"
}

# Succeeds when the file sits inside any of the space-separated globs.
in_globs () {
    local file=$1 glob
    local -a globs
    read -ra globs <<< "$2"
    for glob in ${globs[@]+"${globs[@]}"}; do
        glob_regex "$glob"
        if [[ $file =~ $regex ]]; then
            return 0
        fi
    done
    return 1
}

# Fails on a tracked Swift file that no scope covers, because the analyser would
# never read it, and on one that two scopes cover, because two builds would
# judge it. The base config's own `excluded:` list is not read here: it names
# build output, which git does not track.
check_scopes () {
    local file scope covering checked=0 failed=0
    echo "Checking that one analyse scope covers each tracked Swift file"
    while IFS= read -r -d '' file; do
        # A manifest never compiles into a build log, so no scope can analyse it.
        if [[ $file =~ ^(Packages/[^/]+/[^/]+|SwiftLeedsPackage)/Package\.swift$ ]]; then
            continue
        fi
        checked=$((checked + 1))
        covering=""
        for scope in app tests snapshots; do
            scope_globs "$scope"
            if in_globs "$file" "$included" && ! in_globs "$file" "$also_excluded"; then
                covering="$covering $scope"
            fi
        done
        case "$covering" in
            "")
                fatal "No analyse scope covers $file, so the analyser never reads it. Add its folder to a scope in analyze.sh."
                failed=$((failed + 1))
                ;;
            *" "*" "*)
                fatal "$file is in more than one analyse scope ($covering ), so two builds judge it."
                failed=$((failed + 1))
                ;;
        esac
    done < <(git ls-files -z '*.swift')

    if [ "$checked" -eq 0 ]; then
        fatal "git tracks no Swift files here, so this check is broken."
        return 1
    fi
    echo "Checked $checked file(s): $failed with no scope or more than one"
    [ "$failed" -eq 0 ]
}

if [ "$mode" = scopes ]; then
    check_scopes
    exit
fi

scope_globs "$scope"

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
#
# The rewrite reads lines, not YAML, so a shape it does not expect would leave
# the old list in place and quietly widen the scope. It fails instead when:
#   * either key is missing, or has anything after the colon (`included: [...]`)
#   * a comment or blank line sits inside the `included:` list, with an entry
#     after it
config=".swiftlint-analyze-$scope.yml"
if ! awk -v included="$included" -v also_excluded="$also_excluded" '
    function emit(list,    n, parts, i) {
        n = split(list, parts, " ")
        for (i = 1; i <= n; i++) print "  - \"" parts[i] "\""
    }
    function problem(message) {
        print "error: .swiftlint.yml line " NR ": " message > "/dev/stderr"
        failed = 1
    }
    skipping && /^[[:space:]]*-/ {
        if (gap && !gap_reported) {
            problem("an entry follows a comment or blank line inside included:")
            gap_reported = 1
        }
        next
    }
    skipping && /^[[:space:]]*(#.*)?$/ { gap = 1; print; next }
    { skipping = 0; gap = 0 }
    /^included:/ {
        if ($0 !~ /^included:[[:space:]]*(#.*)?$/) problem("included: must be a block list")
        print; emit(included); skipping = 1; rewrote_included = 1; next
    }
    /^excluded:/ {
        if ($0 !~ /^excluded:[[:space:]]*(#.*)?$/) problem("excluded: must be a block list")
        print; emit(also_excluded); rewrote_excluded = 1; next
    }
    { print }
    END {
        if (!rewrote_included) problem("no included: key found")
        if (!rewrote_excluded) problem("no excluded: key found")
        exit failed
    }
' .swiftlint.yml > "$config"
then
    fatal ".swiftlint.yml does not have the shape this script rewrites, so the $scope scope could not be set. See the lines above."
    exit 1
fi

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
