#!/bin/bash
#
# Installs the macOS build of SwiftLint that .swiftlint-version names, and puts
# it on the PATH of the steps that follow. The macOS jobs run the analyzer rules,
# which need the compiler's view of each file, so they cannot use the Linux
# binary the lint job installs.
#
#     .github/scripts/install-swiftlint.sh
#
# On GitHub Actions the folder is appended to $GITHUB_PATH. Anywhere else the
# script prints the folder instead, for the caller to add.
#
# Bumping .swiftlint-version means replacing the checksum below as well, or the
# download check fails. The Linux job in build.yml keeps its own checksum for its
# own asset.

set -uo pipefail

# The digest of `portable_swiftlint.zip` for the version in .swiftlint-version.
checksum='c1e429b0599cf1b516f369a2d9ec04eaf0e436f3c12b637df8851fa52ff694d0'

cd "$(dirname "$0")/../.." || exit 1

work=${RUNNER_TEMP:-$(mktemp -d)}
log="$work/install-swiftlint-errors.log"
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

if [ ! -f .swiftlint-version ]; then
    fatal "No .swiftlint-version in $(pwd). Run this from the repository."
    exit 1
fi
version=$(cat .swiftlint-version)

archive="$work/portable_swiftlint.zip"
echo "Downloading SwiftLint $version"
if ! curl -sSL --fail --retry 3 -o "$archive" \
    "https://github.com/realm/SwiftLint/releases/download/${version}/portable_swiftlint.zip"
then
    fatal "Could not download SwiftLint $version"
    exit 1
fi

echo "Checking the download against its checksum"
if ! echo "${checksum}  ${archive}" | shasum -a 256 -c -; then
    fatal "The SwiftLint $version download does not match the checksum in install-swiftlint.sh"
    exit 1
fi

echo "Unpacking into $work/swiftlint"
if ! unzip -q -o "$archive" -d "$work/swiftlint"; then
    fatal "Could not unpack the SwiftLint $version download"
    exit 1
fi
# unzip does not always carry the executable bit.
chmod +x "$work/swiftlint/swiftlint"

if [ -n "${GITHUB_PATH:-}" ]; then
    echo "$work/swiftlint" >> "$GITHUB_PATH"
    echo "SwiftLint $version is on the PATH for the steps that follow"
else
    echo "SwiftLint $version is in $work/swiftlint. Add that folder to your PATH."
fi
