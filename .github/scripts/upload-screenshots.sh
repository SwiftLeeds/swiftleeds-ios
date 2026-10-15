#!/bin/bash
#
# Uploads the committed snapshot reference images to Screenshotbot, so a reviewer
# can see each changed image in the pull request. Git still owns the images and
# the simulator job still compares pixels. This only shows them.
#
# Each package with snapshot tests is one Screenshotbot channel, `ios/<Package>`.
# The channels are batched into one pull request status, `ios-snapshot-tests`.
# One upload covers a whole test target folder, because AuthenticationUI keeps
# three `__Snapshots__` folders nested below its target folder.
#
# If any target fails to upload, the script does not tell Screenshotbot the batch
# is complete. A batch marked complete with a channel missing could show green.
#
#     .github/scripts/upload-screenshots.sh
#
# Run locally, after .github/scripts/install-recorder.sh:
#
#     SCREENSHOTBOT_API_KEY=... SCREENSHOTBOT_API_SECRET=... \
#         .github/scripts/upload-screenshots.sh
#
# Other variables: IS_FORK=true skips the upload, because a fork pull request has
# no secrets. RECORDER names a different recorder (the default is
# $HOME/screenshotbot/recorder). RUNNER_TEMP is where the error log goes.

set -uo pipefail

cd "$(dirname "$0")/../.." || exit 1

recorder=${RECORDER:-$HOME/screenshotbot/recorder}
work=${RUNNER_TEMP:-$(mktemp -d)}
log="$work/upload-screenshots-errors.log"
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

if [ "${IS_FORK:-}" = "true" ]; then
    echo "Skipped: a fork pull request has no API key"
    exit 0
fi

if [ -z "${SCREENSHOTBOT_API_KEY:-}" ] || [ -z "${SCREENSHOTBOT_API_SECRET:-}" ]; then
    fatal "SCREENSHOTBOT_API_KEY or SCREENSHOTBOT_API_SECRET is empty"
    exit 1
fi

if [ ! -x "$recorder" ]; then
    fatal "No executable recorder at $recorder. Run .github/scripts/install-recorder.sh first."
    exit 1
fi

if ! targets=$(python3 .github/scripts/list-snapshot-targets.py); then
    fatal "Could not list the snapshot targets"
    exit 1
fi

repo_url='https://github.com/SwiftLeeds/swiftleeds-ios'
batch='ios-snapshot-tests'

uploaded=0
total_images=0
failed=()

while read -r target package; do
    name=$(basename "$package")
    directory="$package/Tests/$target"

    # An empty folder would upload nothing and still look like a success.
    count=$(find "$directory" -type f -name '*.png' 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -eq 0 ]; then
        fatal "[$name] found no images under $directory"
        failed+=("$name")
        continue
    fi
    echo "[$name] $count images"

    if "$recorder" \
        --directory "$directory" --recursive \
        --channel "ios/$name" --batch "$batch" \
        --main-branch main \
        --repo-url "$repo_url"
    then
        echo "[$name] uploaded"
        uploaded=$((uploaded + 1))
        total_images=$((total_images + count))
    else
        fatal "[$name] the upload failed"
        failed+=("$name")
    fi
done <<< "$targets"

if [ ${#failed[@]} -gt 0 ]; then
    fatal "Not marking the batch complete. These targets failed: ${failed[*]}"
    exit 1
fi

echo "Telling Screenshotbot the batch is complete"
if ! "$recorder" --finalize \
    --main-branch main \
    --repo-url "$repo_url"
then
    fatal "Could not mark the $batch batch complete"
    exit 1
fi

echo "Uploaded $uploaded target(s), $total_images images"
