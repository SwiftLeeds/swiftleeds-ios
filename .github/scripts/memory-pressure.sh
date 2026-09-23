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

# Both print a number even when the pattern stops matching. Printing nothing
# would make the subtraction below a unary minus, so a reading that broke
# halfway would print a negative figure on a green job.
compressions () { vm_stat | awk -F'[:.]' '/^Compressions:/ { n = $2 } END { print n + 0 }'; }
swapouts () { vm_stat | awk -F'[:.]' '/^Swapouts:/ { n = $2 } END { print n + 0 }'; }

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
    # Compression is never 0 on a machine doing work, so 0 or less means the
    # counters stopped reading. Print the warning rather than a figure, because
    # a nonsense number in a green log is worse than no number.
    if [ "$compressed_mb" -le 0 ]; then
      echo "::warning::vm_stat gave no usable counters, so there is no memory reading for this step"
      exit 0
    fi
    echo "memory pressure: compressed $compressed_mb MB, swapped out $swapped_mb MB"
    # A green job's log goes unread, so swapping has to announce itself.
    # Every run measured so far swapped 0 MB, so anything above 0 is a change.
    # No threshold on compression: passing runs have ranged from 1660 MB in the
    # package job to 10678 MB in the snapshot job, so a warning would fire on
    # healthy runs.
    if [ "$swapped_mb" -gt 0 ]; then
      echo "::warning::the work swapped $swapped_mb MB, so this runner was short of memory"
    fi
    ;;
  *)
    echo "usage: $(basename "$0") start|report" >&2
    exit 1
    ;;
esac
