#!/usr/bin/env python3
"""Denies `git checkout` and `git switch` in a subagent's shell.

A subagent's Bash directory resets to the directory it started in, usually the
main checkout, after every call. So a checkout it means for a worktree can move
the main checkout, under every session that shares it.

A call that carries `agent_id` came from a subagent. A main session has none,
and is always allowed.

The trigger is git in command position of any line or pipeline, after
assignments, a wrapper or a shell keyword. Heredoc bodies are skipped, so a
commit message naming the words passes.

Known gaps: it reads the command text only, so git inside `bash -c` or a script
gets through, and so do other commands that move a branch, such as
`gh pr checkout` and `git rebase <base> <branch>`.

It fails open. Bad input or unbalanced quotes let the command through, and it
never exits 2, which would block every Bash call.
"""
import json
import os
import re
import shlex
import sys

BLOCKED = {"checkout", "switch"}
# git options that take a separate value, so the value is not the subcommand.
VALUE_OPTIONS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--config-env"}
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
KEYWORDS = {"if", "then", "elif", "else", "while", "until", "do", "{", "!"}
# Each wrapper maps to the options that take a separate value.
WRAPPERS = {"env": {"-u", "-C", "-S"}, "command": set(), "time": set(), "exec": set()}
HEREDOC = re.compile(
    r"(?<!<)<<(?!<)(?P<dash>-?)\s*(?P<quote>['\"]?)"
    r"(?P<word>[^\s'\"<>|&;()]+)(?P=quote)"
)
ARITHMETIC = re.compile(r"\$\(\(.*?\)\)")


def refuse(subcommand):
    """Prints a deny decision that names the subcommand, and exits."""
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                f"A subagent may not run `git {subcommand}`, which can move the branch of "
                "the checkout that every session shares. To restore a file, use `git "
                "restore`. To change branch, report `Needs: <the checkout you need>`, and "
                "the main session runs it."
            ),
        }
    }))
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
        opener = HEREDOC.search(ARITHMETIC.sub("", line))
        if opener:
            terminator = opener.group("word")
            strip_tabs = opener.group("dash") == "-"
        yield line


def segments(text):
    """Yields the token list of each simple command in the text."""
    lexer = shlex.shlex(text, posix=True, punctuation_chars="();<>|&\n`")
    lexer.whitespace_split = True
    lexer.whitespace = " \t\r"
    lexer.commenters = ""
    segment = []
    in_comment = False
    for token in lexer:
        punctuation = all(char in lexer.punctuation_chars for char in token)
        if in_comment:
            if punctuation and "\n" in token:
                in_comment = False
                yield segment
                segment = []
        elif token.startswith("#"):
            in_comment = True
        elif punctuation:
            yield segment
            segment = []
        else:
            segment.append(token)
    yield segment


def command_words(segment):
    """Returns the segment from its command word on, past assignments, keywords and wrappers."""
    words = list(segment)
    while words:
        word = words[0]
        if ASSIGNMENT.match(word) or word in KEYWORDS:
            words.pop(0)
        elif os.path.basename(word) in WRAPPERS:
            wrapper = os.path.basename(words.pop(0))
            while words and words[0].startswith("-"):
                option = words.pop(0)
                if option in WRAPPERS[wrapper] and words:
                    words.pop(0)
        else:
            break
    return words


def subcommand_after(tokens):
    """Returns the first word after git's own options, or None if there is none."""
    rest = iter(tokens)
    for token in rest:
        if token in VALUE_OPTIONS:
            next(rest, None)
        elif not token.startswith("-"):
            return token
    return None


def check(command):
    """Refuses the first blocked git subcommand in the command."""
    # Join continuations after the heredoc bodies are gone, so a body line ending
    # in a backslash cannot swallow its terminator.
    code = "\n".join(code_lines(command)).replace("\\\n", " ")
    for segment in segments(code):
        words = command_words(segment)
        if words and os.path.basename(words[0]) == "git":
            subcommand = subcommand_after(words[1:])
            if subcommand in BLOCKED:
                refuse(subcommand)


try:
    payload = json.load(sys.stdin)
    if payload.get("agent_id"):
        check(payload.get("tool_input", {}).get("command", ""))
except (ValueError, AttributeError):
    pass

sys.exit(0)
