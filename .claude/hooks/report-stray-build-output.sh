#!/bin/bash
# SessionStart hook. Reports build output that nothing else shows.
#
# A PreToolUse hook sees only Claude Code's Bash tool, never Xcode or a command
# typed in a terminal. .gitignore ignores .build/ and dd/, so neither appears in
# git status, and the folders grow unseen.
#
# One dd at the repository root is the sanctioned derived data path, so it is
# only reported once there are two, which breaks the one-path-per-checkout rule.
#
# The repository root comes from the `cwd` field of the hook's input, because in
# a session that enters a worktree $CLAUDE_PROJECT_DIR stays on the main
# checkout. It falls back to $CLAUDE_PROJECT_DIR, then $PWD. The hook needs jq
# and exits quietly without it. It never fails a session start.
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)

cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
repo=""
if [ -n "$cwd" ]; then
  repo=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
fi
[ -n "$repo" ] || repo="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -d "$repo/Packages" ] || exit 0

# Prints a size in kilobytes as K, M or G.
human() {
  awk -v k="$1" 'BEGIN {
    if (k >= 1048576) printf "%.1fG", k / 1048576
    else if (k >= 1024) printf "%.0fM", k / 1024
    else printf "%dK", k
  }'
}

# A per-package build or derived data directory is never right here. Packages
# sit at Packages/<Name> or Packages/<Folder>/<Name>.
stray=$(du -sk "$repo"/Packages/*/.build "$repo"/Packages/*/dd* "$repo"/Packages/*/*/.build "$repo"/Packages/*/*/dd* 2>/dev/null | sort -rn)
# Derived data at the root is right, but only one of them.
roots=$(du -sk "$repo"/dd* 2>/dev/null | sort -rn)

lines=()

if [ -n "$stray" ]; then
  count=$(wc -l <<<"$stray" | tr -d ' ')
  total=$(awk '{s += $1} END {print s}' <<<"$stray")
  top=$(head -1 <<<"$stray")
  top_path=$(cut -f2- <<<"$top")
  noun="folders"
  [ "$count" -eq 1 ] && noun="folder"
  lines+=("Stray package build output: $count $noun, $(human "$total"). Largest: ${top_path#"$repo"/}, $(human "$(cut -f1 <<<"$top")"). The sanctioned route is .claude/scripts/package-test.sh.")
fi

root_count=$(wc -l <<<"$roots" | tr -d ' ')
if [ -n "$roots" ] && [ "$root_count" -gt 1 ]; then
  count="$root_count"
  total=$(awk '{s += $1} END {print s}' <<<"$roots")
  lines+=("$count derived data paths at the repository root, $(human "$total"). One per checkout is the rule; keep the newest and delete the rest.")
fi

[ ${#lines[@]} -eq 0 ] && exit 0

printf '%s\n' "${lines[@]}" | jq -Rs '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: .
  }
}'
exit 0
