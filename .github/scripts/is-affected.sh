#!/bin/bash
#
# Decides which snapshot targets a pull request has to run. A pull request runs
# only the targets its diff can change: a package's own files, or those of a
# local package it depends on, directly or not. A change to CI or to the app
# project runs them all. A push (BASE_REF empty or unset) always runs them all,
# which catches anything a pull request skipped.
#
# Run it from the repository root, with BASE_REF set to the pull request's base
# branch. It takes exactly one argument:
#
#     .github/scripts/is-affected.sh all
#     .github/scripts/is-affected.sh <package-path>
#
# `all` asks whether this run tests everything. A package path, such as
# Packages/DesignSystem/UIDesign, asks whether that package is affected.
#
# The exit status carries the answer, and a caller must read it in three ways:
#
#     0  yes: the run tests everything, or the package is affected
#     1  no: the package cannot be affected (for `all`, the run is not total)
#     2 or more  an error, such as a wrong argument
#
# A caller must treat anything other than exactly 1 as "run it", so an error
# never skips a test.
#
# When the dependencies cannot be listed, or the list does not name the package
# itself, the package counts as affected. When `git diff` fails, everything
# runs. Each of those paths prints a warning and appends a line to
# is-affected-errors.log in RUNNER_TEMP (or TMPDIR, or /tmp). The log holds
# failures only.
#
# It never reads standard input: the caller loops over a list on another file
# descriptor, and a command that read stdin would swallow the rest of it.

set -uo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: is-affected.sh all | <package-path>" >&2
  exit 2
fi
target="$1"

log_file="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/is-affected-errors.log"

# Warns on the console and records the failure in the log.
warn() {
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "::warning::$1" >&2
  else
    echo "warning: $1" >&2
  fi
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $1" >> "$log_file"
}

base_ref="${BASE_REF:-}"
changed=""
run_all=true
# --no-renames lists both paths of a moved file, so a file moved into
# a package still counts as a change where it came from.
if [ -n "$base_ref" ]; then
  if changed=$(git diff --name-only --no-renames "origin/$base_ref...HEAD"); then
    run_all=false
    if grep -qE '^(\.github/|SwiftLeeds\.xcodeproj/)' <<< "$changed"; then
      run_all=true
    fi
  else
    warn "git diff against origin/$base_ref failed, so every target runs"
  fi
fi

if [ "$target" = "all" ]; then
  if $run_all; then
    exit 0
  fi
  exit 1
fi

$run_all && exit 0

# Prints the repository paths of a package and of every local package
# it depends on, directly or not.
local_package_paths() {
  (cd "$1" && swift package show-dependencies --format json) \
    | jq -r '.. | objects | select(has("path")) | .path' \
    | grep -v -e '/\.build/' -e '/SourcePackages/' \
    | sed "s|^$(pwd -P)/||"
}

# When the dependencies cannot be listed, or the list does not name
# the package itself, the package counts as affected. So a failure
# here runs a test rather than skipping one.
if ! paths=$(local_package_paths "$target"); then
  warn "cannot list the dependencies of $target, so it counts as affected"
  exit 0
fi
if ! grep -qx "$target" <<< "$paths"; then
  warn "the dependencies of $target do not name it, so it counts as affected"
  exit 0
fi
for path in $paths; do
  grep -q "^$path/" <<< "$changed" && exit 0
done
exit 1
