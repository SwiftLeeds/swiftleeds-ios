#!/usr/bin/env python3
"""Denies a swift command that would write a per-package .build directory.

Run from inside a package, or pointed at one, swift writes
Packages/<Folder>/<Name>/.build. That folder holds a full copy of every
dependency checkout and build product, many gigabytes in all. The sanctioned
route is .claude/scripts/package-test.sh, which passes
--scratch-path <repo>/.build-shared.

Resolution writes the bulk of it, so `swift package resolve` counts as much as
`swift build`. The trigger is the word `swift` in command position, not a
substring: a commit message or an rg pattern naming `swift test` must pass.

The check reads only the command text, so it needs no repository root and works
the same in the main checkout and in a worktree.

It fails open. Bad input, unbalanced quotes or an unrecognised shape let the
command through, and it never exits 2, which would block every Bash call.
"""
import json
import re
import shlex
import sys

ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
HARMLESS = {"--version", "-version", "format", "demangle"}
SANCTIONED = ".claude/scripts/package-test.sh <PackageName>"


def refuse(reason):
    """Prints a deny decision with the given reason and exits."""
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


try:
    payload = json.load(sys.stdin)
except ValueError:
    sys.exit(0)

command = payload.get("tool_input", {}).get("command", "")
if not command:
    sys.exit(0)

lexer = shlex.shlex(command, posix=True, punctuation_chars=True)
lexer.whitespace_split = True
try:
    tokens = list(lexer)
except ValueError:
    # Unbalanced quotes. The shell reports the syntax error itself.
    sys.exit(0)

while tokens and ASSIGNMENT.match(tokens[0]):
    tokens.pop(0)

if not tokens or tokens[0] != "swift":
    sys.exit(0)

args = tokens[1:]
if not args or args[0] in HARMLESS or "--help" in args or "-h" in args:
    sys.exit(0)

scratch = None
for index, arg in enumerate(args):
    if arg == "--scratch-path" and index + 1 < len(args):
        scratch = args[index + 1]
    elif arg.startswith("--scratch-path="):
        scratch = arg.split("=", 1)[1]

if scratch is None:
    refuse(
        "This swift command has no --scratch-path, so it writes "
        "Packages/<Folder>/<Name>/.build, a full copy of every dependency. Run "
        f"{SANCTIONED} instead, or pass "
        '--package-path Packages/<Folder>/<Name> --scratch-path "$(git rev-parse '
        '--show-toplevel)/.build-shared" from the repository root.'
    )

if scratch == ".build" or scratch.endswith("/.build") or "Packages/" in scratch:
    refuse(
        f"The --scratch-path '{scratch}' is the per-package build directory this "
        "rule exists to prevent. Point it at <repo>/.build-shared, or run "
        f"{SANCTIONED}."
    )

sys.exit(0)
