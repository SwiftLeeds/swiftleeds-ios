#!/usr/bin/env bash
# Builds the App Clip for one brand, launches it on a simulator, and fails if
# the process is gone a few seconds later. A trap at launch compiles cleanly,
# so only running the App Clip can catch it.
#
# Usage: .github/scripts/launch-app-clip.sh <configuration> <bundle id> <derived data path>
#   .github/scripts/launch-app-clip.sh Debug uk.co.swiftleeds.SwiftLeeds.Clip "$TMPDIR/app-clip-dd-swiftleeds"
#   .github/scripts/launch-app-clip.sh Debug-KotlinLeeds uk.co.kotlinleeds.KotlinLeeds.Clip "$TMPDIR/app-clip-dd-kotlinleeds"
# Give each brand its own folder: switching configuration in one folder makes
# Xcode delete the other brand's products.
set -euo pipefail

usage="usage: $0 <configuration> <bundle id> <derived data path>"
configuration="${1:?$usage}"
bundle_id="${2:?$usage}"
derived_data="${3:?$usage}"

# A relative derived data path is the caller's. Every other path below is the
# repository's, wherever this runs from.
mkdir -p "$derived_data"
derived_data=$(cd "$derived_data" && pwd)
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

# The same device and runtime the snapshot job pins, for the same reason: an
# image roll must not change the simulator silently.
device_name="iPhone 17 Pro"
runtime="com.apple.CoreSimulator.SimRuntime.iOS-26-5"
seconds_alive=10

udid=$(xcrun simctl list devices available --json \
  | jq -r --arg runtime "$runtime" --arg name "$device_name" \
    '.devices[$runtime][]? | select(.name == $name) | .udid' \
  | head -n 1)
if [ -z "$udid" ]; then
  echo "::error::No $device_name simulator for $runtime"
  exit 1
fi

# Timestamps each phase, so a slow run's log shows where the time went.
say() { echo "$(date -u +%H:%M:%S) $*"; }

# The build names no particular simulator, as the app build jobs do. A generic
# destination builds every architecture, so ARCHS keeps it to the runner's own.
#
# The boot used to run in the background during this build, and both were slow
# because they share the runner's cores. One after the other, measured on CI
# 2026-09-22: build 73s and 77s, boot 64s and 75s, install and launch 54s and
# 63s, against jobs of 10m0s and 8m33s while they overlapped. Each phase is
# timed below, so a run says what it spent where.
say "Building the $configuration App Clip"
xcodebuild build -quiet -project SwiftLeeds.xcodeproj -scheme SwiftLeedsAppClip \
  -configuration "$configuration" \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$derived_data" \
  -skipPackagePluginValidation \
  ARCHS=arm64 \
  CODE_SIGNING_ALLOWED=NO

say "Booting $device_name ($runtime)"
xcrun simctl bootstatus "$udid" -b > /dev/null

# Only a crash report written after this moment belongs to this launch.
launch_marker=$(mktemp)

# Leaves the simulator clean for the next brand, whether this one passed or not.
trap 'xcrun simctl terminate "$udid" "$bundle_id" 2> /dev/null || true
      xcrun simctl uninstall "$udid" "$bundle_id" 2> /dev/null || true
      rm -f "$launch_marker"' EXIT

say "Installing and launching $bundle_id"
xcrun simctl install "$udid" "$derived_data/Build/Products/$configuration-iphonesimulator/SwiftLeedsAppClip.app"

# Prints "<bundle id>: <pid>". The pid is a process on the host, so ps can see it.
launch_output=$(xcrun simctl launch "$udid" "$bundle_id")
pid="${launch_output##*: }"

# Closes the install and launch phase, so the wait below is not counted in it.
say "Launched. Watching it for ${seconds_alive}s"
sleep "$seconds_alive"

if ! ps -p "$pid" > /dev/null; then
  echo "::error::The $configuration App Clip ($bundle_id) was gone ${seconds_alive}s after launch"
  # The crash reporter writes its file some seconds after the crash.
  report=""
  for _ in $(seq 30); do
    report=$(find "$HOME/Library/Logs/DiagnosticReports" -name 'SwiftLeedsAppClip*' \
      -newer "$launch_marker" 2> /dev/null | head -n 1 || true)
    [ -n "$report" ] && break
    sleep 1
  done
  if [ -n "$report" ]; then
    echo "Crash report: $report"
    head -n 60 "$report"
  else
    echo "No crash report appeared within 30s"
  fi
  exit 1
fi

echo "The $configuration App Clip ($bundle_id) is still running ${seconds_alive}s after launch"
