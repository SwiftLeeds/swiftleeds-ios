#!/bin/bash
#
# Installs the Screenshotbot recorder, the command line tool that uploads
# snapshot images, at $HOME/screenshotbot/recorder. That is where Screenshotbot's
# own `curl https://cdn.screenshotbot.io/recorder.sh | sh` route puts it.
#
#     .github/scripts/install-recorder.sh
#
# The official route asks the server for the newest version and runs whatever it
# downloads. This script names one version and checks the download against a
# checksum first, so a change on their side cannot reach a run unnoticed.
#
# Bumping the version means replacing every checksum below as well, or the
# download check fails. Fetch each artifact once and run `shasum -a 256` on it.

set -uo pipefail

# Keep the trailing slash: the download address is built by joining on it.
version='releases/2.18.15/'

# The digest of each installer for the version above.
checksum_linux='ef6e430569e04c19733166885064a189ccbf2b409e07847c48d7c1504422dc02'
checksum_linux_arm64='ec7b021d56545ec22bd4e231b0dd565a57132c1a07e2e1255b97e90898972078'
checksum_darwin='5d4badcab5ef25357757ce1e6e6edb561eedaffd1fafa143cb00c375dd7fc6a6'

work=${RUNNER_TEMP:-$(mktemp -d)}
log="$work/install-recorder-errors.log"
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

system=$(uname -s)
machine=$(uname -m)
case "$system" in
    Linux)
        if [ "$machine" = "aarch64" ] || [ "$machine" = "arm64" ]; then
            artifact='recorder-linux-arm64'
            checksum=$checksum_linux_arm64
        else
            artifact='recorder-linux'
            checksum=$checksum_linux
        fi
        ;;
    Darwin)
        artifact='recorder-darwin'
        checksum=$checksum_darwin
        ;;
    *)
        fatal "No Screenshotbot recorder for $system $machine"
        exit 1
        ;;
esac

# A folder of its own, so the installer cannot mix with other files.
download="$work/recorder-download"
rm -rf "$download"
mkdir -p "$download" || { fatal "Could not create $download"; exit 1; }
installer="$download/$artifact"

echo "Downloading the Screenshotbot recorder $version ($artifact)"
if ! curl -sSL --fail --retry 3 -o "$installer" \
    "https://cdn.screenshotbot.io/artifact/${version}${artifact}"
then
    fatal "Could not download $artifact from Screenshotbot"
    exit 1
fi

echo "Checking the download against its checksum"
if ! echo "${checksum}  ${installer}" | shasum -a 256 -c -; then
    fatal "The $artifact download does not match the checksum in install-recorder.sh"
    exit 1
fi

# The installer is a self-extracting archive. Screenshotbot's script runs it
# with sh and then deletes it, and so does this one.
echo "Running the installer"
if ! sh "$installer"; then
    fatal "The $artifact installer failed"
    exit 1
fi
rm -f "$installer"

recorder="$HOME/screenshotbot/recorder"
if [ ! -x "$recorder" ]; then
    fatal "The installer did not leave an executable recorder at $recorder"
    exit 1
fi

echo "Checking the installed recorder"
if ! "$recorder" --version; then
    fatal "The installed recorder would not report its version"
    exit 1
fi
