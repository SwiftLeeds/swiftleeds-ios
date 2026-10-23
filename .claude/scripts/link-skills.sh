#!/bin/bash
#
# Links each installed skill into .claude/skills so Claude Code can see it.
#
# `npx skills experimental_install` restores every skill in skills-lock.json into
# .agents/skills/<name>/ but creates no .claude/skills/<name> link. This makes
# the missing links. It only creates: a path that already exists (a link, a
# folder or a file) is left alone, and nothing is replaced or deleted.
#
# Run from the repository root. Failures go to .claude/scripts/link-skills.log.

set -u

log=".claude/scripts/link-skills.log"
created=0

if [ ! -d .agents/skills ]; then
    echo "No .agents/skills folder here. Run npx skills experimental_install from the repository root first." >&2
    exit 1
fi

mkdir -p .claude/skills

for source in .agents/skills/*/; do
    # An empty folder leaves the glob unexpanded.
    [ -d "$source" ] || continue
    name=$(basename "$source")
    target=".claude/skills/$name"
    # -e misses a broken link, so test -L as well.
    if [ -e "$target" ] || [ -L "$target" ]; then
        continue
    fi
    if message=$(ln -s "../../.agents/skills/$name" "$target" 2>&1); then
        echo "linked $name"
        created=$((created + 1))
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') could not link $name: $message" >>"$log"
        echo "could not link $name (see $log)" >&2
    fi
done

echo "$created linked"
