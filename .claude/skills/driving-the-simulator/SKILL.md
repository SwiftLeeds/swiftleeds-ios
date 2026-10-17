---
name: driving-the-simulator
description: "Drive the app live in an iOS simulator through Xcode 27's Device Hub: launch, tap, swipe, type, capture screen and UI hierarchy."
---
# Driving the simulator

TRIGGER when: asked to verify, try or look at the app on a simulator, to check a UI change works for real, or to debug a tap or navigation problem.
DO NOT TRIGGER when: unit tests only, build-only requests, code review, or a static render. For a PNG of one view, record a snapshot test.

**Run this in a subagent, never the main session.** Xcode's server says so in every reply. Give the subagent this file.

Script: `.claude/scripts/xcode-device.py` (run with `python3`, from the checkout you want to test). It keeps state per checkout, so worktrees do not collide.

| Command | Does |
|---|---|
| `doctor` | PASS or FAIL per check. Run first when anything breaks |
| `start [name]` | Opens the project, starts a session, saves it |
| `run [arg ...]` | Builds, installs, launches. Minutes. Prints progress |
| `do "<cmd>"` | One interaction, then capture. `do ""` only captures |
| `shot <png>` | True 3x screenshot via `simctl` |
| `end` | Closes the session. Always do this |
| `status` | Shows the saved state |
| `syntax` | Prints the live tool schemas |

## Rules

- **Sessions die after about two idle minutes** (alive at 87s, dead at 150s). `Session not found` means run `start` again, then `run`. Work fast between calls.
- `do` prints four paths. **Read the hierarchy**, find the element, **tap its `hitPoint`**. Never guess from a screenshot. Fall back to estimating only after a `hitPoint` tap was tried and recapture shows no effect.
- **Navigate with the thumbnail.** Take `shot` only to judge type, spacing or colour: a 1206x2622 PNG is expensive.
- A system alert (notifications on first launch) comes from `com.apple.springboard` and swallows taps. Tap its button first. If a line shows `activationBundleId`, pass it.
- Hierarchy points are 1x (402x874). Tap in those units.
- After any change, recapture and check. One retry, then report.

## Commands for `do`

`t X Y` tap. `t X1 Y1 f X2 Y2 0.3` swipe. `d X Y` double tap. `sender keyboard kbd text` type (last in chain). `w 0.5` wait. `b h` home. `orientation landscapeLeft`. Chain with spaces. `syntax` prints the schemas but only gives the example `t 100 200`; the full grammar is in Apple's exported skill (`xcrun agent skills export`).

## Facts a reader should know

- `ios-simulator` still works for `simctl`. `ios-simulator-skill`'s interaction scripts need `idb`, **which is not part of this setup**, so they cannot run. Use this skill.
- Xcode's approval attaches to the interpreter's signing identity, so `xcrun mcp-server status` lists `org.python.python`. Any Python process on the Mac can drive Xcode within this folder.
- Errors are logged to `~/.cache/swiftleeds-device/error.log`.

Verified 2026-10-09 on Xcode 27.0 (27A266a): start, run, tap, shot, end, against iOS 27.0.
