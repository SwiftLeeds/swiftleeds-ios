#!/bin/bash
# Reports how much memory the work between `start` and `report` cost.
#
# macOS compresses pages before it swaps, so swap alone misses a runner under
# pressure. Both counters are cumulative since boot, so `start` records them
# and `report` prints the difference.
#
# Compare swap between runs, not compression. Compression is a total over the
# window, so a longer run compresses more for that reason alone. Swap has no
# such problem: 0 means the runner never got desperate, however long it ran.
#
#   memory-pressure.sh start
#   ...work...
#   memory-pressure.sh report
#
# Runs locally as well as on CI.
set -euo pipefail

state="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/memory-pressure-start"

compressions () { vm_stat | awk -F'[:.]' '/^Compressions:/ { print $2 + 0 }'; }
swapouts () { vm_stat | awk -F'[:.]' '/^Swapouts:/ { print $2 + 0 }'; }

case "${1:-}" in
  start)
    printf '%s %s\n' "$(compressions)" "$(swapouts)" > "$state"
    ;;
  report)
    if [ ! -f "$state" ]; then
      echo "::warning::memory-pressure.sh report ran without a start, so there is nothing to report"
      exit 0
    fi
    read -r compressions_before swapouts_before < "$state"
    rm -f "$state"
    # MB, to compare with the runner's 7 GB.
    page_size=$(sysctl -n hw.pagesize)
    compressed_mb=$(( ($(compressions) - compressions_before) * page_size / 1048576 ))
    swapped_mb=$(( ($(swapouts) - swapouts_before) * page_size / 1048576 ))
    echo "memory pressure: compressed $compressed_mb MB, swapped out $swapped_mb MB"
    # An awk pattern that stops matching prints 0, which reads as a quiet
    # runner. Compression is never 0 on a machine doing work.
    if [ "$compressed_mb" -eq 0 ]; then
      echo "::warning::vm_stat reported no compression, so these memory figures are not trustworthy"
    fi
    # A green job's log goes unread, so swapping has to announce itself.
    # Every run measured so far swapped 0 MB, so anything above 0 is a change.
    # No threshold on compression: it has ranged 1660 to 10678 MB on a passing
    # run, so a warning there would fire on healthy runs.
    if [ "$swapped_mb" -gt 0 ]; then
      echo "::warning::the work swapped $swapped_mb MB, so this runner was short of memory"
    fi
    ;;
  *)
    echo "usage: $(basename "$0") start|report" >&2
    exit 1
    ;;
esac
