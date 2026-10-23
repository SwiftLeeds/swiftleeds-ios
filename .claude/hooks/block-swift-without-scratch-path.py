#!/usr/bin/env python3
"""Denies a swift command that would write a per-package .build directory.

Run from inside a package, or pointed at one, swift writes
Packages/<Folder>/<Name>/.build. That folder holds a full copy of every
dependency checkout and build product, many gigabytes in all. The sanctioned
route is .claude/scripts/package-test.sh, which passes
--scratch-path <repo>/.build-shared.

Resolution writes the bulk of it, so `swift package resolve` counts as much as
`swift build`. The trigger is a swift command word (`swift` or a
`swift-build`-style tool, by any path) in command position of any line or
pipeline segment, after `xcrun`, `env` or `command`. Heredoc bodies are skipped.
It is not a substring: a commit message or an rg pattern naming `swift test`
must pass.

The check reads only the command text, so it needs no repository root and works
the same in the main checkout and in a worktree.

It fails open. Bad input, unbalanced quotes or an unrecognised shape let the
command through, and it never exits 2, which would block every Bash call.
"""
import json
import os
import re
import shlex
import sys

ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
HEREDOC = re.compile(r"<<(?P<dash>-?)\s*(?P<quote>['\"]?)(?P<word>\w+)(?P=quote)")
# Each wrapper maps to the options that take a separate value.
WRAPPERS = {
    "xcrun": {"-sdk", "--sdk", "-toolchain", "--toolchain"},
    "env": {"-u", "-C", "-S"},
    "command": set(),
}
SWIFT_TOOLS = {"swift-build", "swift-test", "swift-package", "swift-run"}
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

def code_lines(text):
    """Yields each line of the command, skipping heredoc bodies."""
    terminator = None
    strip_tabs = False
    for line in text.splitlines():
        if terminator is not None:
            body = line.lstrip("\t") if strip_tabs else line
            if body == terminator:
                terminator = None
            continue
        opener = HEREDOC.search(line)
        if opener:
            terminator = opener.group("word")
            strip_tabs = opener.group("dash") == "-"
        yield line


def segments(line):
    """Yields the token list of each simple command on the line."""
    lexer = shlex.shlex(line, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    try:
        tokens = list(lexer)
    except ValueError:
        # Unbalanced quotes. The shell reports the syntax error itself.
        return
    segment = []
    for token in tokens:
        if all(char in lexer.punctuation_chars for char in token):
            yield segment
            segment = []
        else:
            segment.append(token)
    yield segment


def swift_args(segment):
    """Returns the swift arguments of a segment, or None if it is not swift."""
    segment = list(segment)
    while segment and ASSIGNMENT.match(segment[0]):
        segment.pop(0)
    while segment and os.path.basename(segment[0]) in WRAPPERS:
        wrapper = os.path.basename(segment.pop(0))
        while segment:
            token = segment[0]
            if token.startswith("-"):
                segment.pop(0)
                if token in WRAPPERS[wrapper] and segment:
                    segment.pop(0)
            elif wrapper == "env" and ASSIGNMENT.match(token):
                segment.pop(0)
            else:
                break
    if not segment:
        return None
    name = os.path.basename(segment[0])
    if name == "swift":
        return segment[1:]
    if name in SWIFT_TOOLS:
        return [name[len("swift-"):]] + segment[1:]
    return None


def check(args):
    """Refuses a swift invocation that would write a per-package .build."""
    if not args or args[0] in HARMLESS or "--help" in args or "-h" in args:
        return

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


for line in code_lines(command):
    for segment in segments(line):
        args = swift_args(segment)
        if args is not None:
            check(args)

sys.exit(0)
