#!/usr/bin/env python3
"""Drive an iOS simulator through Xcode 27's Device Hub, one command at a time.

Each run starts Xcode's `mcpbridge`, calls a few DeviceInteraction tools and exits. The
session is kept in a state file, so one session spans many runs, and none of Xcode's 54 tool
schemas ever enter the agent's prompt.

Commands:
    doctor              Check the setup. One PASS or FAIL line each. Exits 1 on any FAIL.
    syntax              Print the live input schema of the five device tools.
    start [name]        Open the workspace, start a session, save its state.
    run [arg ...]       Build, install and launch. Arguments are passed to the app.
    do "<command>"      One interaction plus capture. "" captures without interacting.
    shot <path>         Native 3x screenshot of the session's device (simctl).
    end                 Close the session and delete the state.
    status              Print the saved state.

State is per checkout (git toplevel), in ~/.cache/swiftleeds-device/. Progress goes to stdout.
Failures also go to ~/.cache/swiftleeds-device/error.log, with a timestamp.
"""

import collections
import datetime
import glob
import hashlib
import json
import os
import queue
import subprocess
import sys
import threading
import time
import uuid

CACHE = os.path.expanduser("~/.cache/swiftleeds-device")
LOG = os.path.join(CACHE, "error.log")
DEVICE_TOOLS = [
    "DeviceInteractionStartWorkspaceSession",
    "DeviceInteractionInstallAndRun",
    "DeviceInteractionSynthesize",
    "DeviceInteractionEndSession",
    "DeviceInteractionStartSession",
]
SHORT_TIMEOUT = 120
BUILD_TIMEOUT = 1800
HEARTBEAT = 10


class DeviceError(Exception):
    """A failure the caller should see as one line."""


def log_failure(message):
    """Append a timestamped line to the error log."""
    os.makedirs(CACHE, exist_ok=True)
    stamp = datetime.datetime.now().isoformat(timespec="seconds")
    with open(LOG, "a", encoding="utf-8") as handle:
        handle.write("%s %s\n" % (stamp, message))


def say(text):
    """Print a progress line and flush it."""
    print(text, flush=True)


# MARK: Checkout

def checkout_root():
    """The git toplevel of the invoking directory. A worktree gets its own."""
    done = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True
    )
    if done.returncode != 0:
        raise DeviceError("not inside a git checkout (run from the repo or a worktree)")
    return done.stdout.strip()


def find_project(root):
    """The one .xcodeproj in the checkout root."""
    found = sorted(glob.glob(os.path.join(root, "*.xcodeproj")))
    if len(found) != 1:
        raise DeviceError("expected one .xcodeproj in %s, found %d" % (root, len(found)))
    return found[0]


def state_path(root):
    """The state file for a checkout, named by a hash of its path."""
    digest = hashlib.sha1(root.encode("utf-8")).hexdigest()[:16]
    return os.path.join(CACHE, "%s.json" % digest)


def load_state(root):
    """The saved session state for a checkout, or None when there is none."""
    try:
        with open(state_path(root), encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        return None


def save_state(root, state):
    """Write the session state for a checkout."""
    os.makedirs(CACHE, exist_ok=True)
    with open(state_path(root), "w", encoding="utf-8") as handle:
        json.dump(state, handle, indent=2)


def require_state(root):
    """The saved session state, or a DeviceError when `start` has not run."""
    state = load_state(root)
    if state is None:
        raise DeviceError("no session for %s. Run `start` first" % root)
    return state


# MARK: Bridge

class Bridge:
    """One `mcpbridge` process. Reads run on a thread so every wait can time out."""

    def __init__(self, session_id):
        found = subprocess.run(["xcrun", "-f", "mcpbridge"], capture_output=True, text=True)
        if found.returncode != 0:
            raise DeviceError("xcrun cannot find mcpbridge (is Xcode 27 selected?)")
        self.path = found.stdout.strip()
        env = dict(os.environ, MCP_XCODE_SESSION_ID=session_id)
        self.proc = subprocess.Popen(
            [self.path],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env,
        )
        self.lines = queue.Queue()
        self.stderr_tail = collections.deque(maxlen=10)
        self.next_id = 1
        threading.Thread(target=self._pump_stdout, daemon=True).start()
        threading.Thread(target=self._pump_stderr, daemon=True).start()
        self._request(
            "initialize",
            {
                "protocolVersion": "2025-06-18",
                "capabilities": {},
                "clientInfo": {"name": "xcode-device-cli", "version": "2.0"},
            },
            SHORT_TIMEOUT,
            "initialize",
        )
        self._send({"jsonrpc": "2.0", "method": "notifications/initialized"})

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()

    def close(self):
        try:
            self.proc.stdin.close()
        except OSError:
            pass
        self.proc.terminate()
        try:
            self.proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            self.proc.kill()

    def _pump_stdout(self):
        for line in self.proc.stdout:
            self.lines.put(line)
        self.lines.put(None)

    def _pump_stderr(self):
        for line in self.proc.stderr:
            self.stderr_tail.append(line.rstrip())

    def _send(self, payload):
        try:
            self.proc.stdin.write(json.dumps(payload) + "\n")
            self.proc.stdin.flush()
        except OSError:
            raise DeviceError("the bridge closed its input. %s" % self._tail())

    def _tail(self):
        return " | ".join(self.stderr_tail)

    def _request(self, method, params, timeout, label):
        request_id = self.next_id
        self.next_id += 1
        self._send({"jsonrpc": "2.0", "id": request_id, "method": method, "params": params})
        started = time.monotonic()
        next_beat = HEARTBEAT
        while True:
            elapsed = time.monotonic() - started
            if elapsed > timeout:
                raise DeviceError("%s timed out after %ds" % (label, timeout))
            try:
                line = self.lines.get(timeout=1)
            except queue.Empty:
                if elapsed >= next_beat:
                    say("  waiting for %s: %ds" % (label, elapsed))
                    next_beat += HEARTBEAT
                continue
            if line is None:
                raise DeviceError("the bridge closed before it answered %s. %s" % (label, self._tail()))
            try:
                message = json.loads(line)
            except json.JSONDecodeError:
                continue
            if message.get("id") != request_id:
                continue
            if "error" in message:
                raise DeviceError("%s returned an error: %s" % (label, json.dumps(message["error"])))
            return message["result"]

    def list_tools(self):
        return self._request("tools/list", {}, SHORT_TIMEOUT, "tools/list")["tools"]

    def call(self, tool, arguments, timeout=SHORT_TIMEOUT):
        result = self._request(
            "tools/call", {"name": tool, "arguments": arguments}, timeout, tool
        )
        if result.get("isError"):
            raise DeviceError("%s failed: %s" % (tool, text_of(result)))
        return structured(result)


def text_of(result):
    """The text blocks of a tool result, joined with spaces."""
    return " ".join(
        block.get("text", "") for block in result.get("content", []) if block.get("type") == "text"
    )


def structured(result):
    """A tool result as a dict: its structured content, its text as JSON, or {"text": ...}."""
    if "structuredContent" in result:
        return result["structuredContent"]
    text = text_of(result)
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return {"text": text}


def is_dead_session(error):
    """Whether an error says the server no longer knows the session."""
    text = str(error).lower()
    return "session" in text and any(
        phrase in text
        for phrase in ("not found", "no such", "unknown", "doesn't exist", "does not exist")
    )


def session_alive(bridge, state):
    """A capture with no command. The server answers 'not found' for a session it forgot."""
    try:
        bridge.call("DeviceInteractionSynthesize", {"interactSessionKey": state["interactionSessionKey"]})
        return True
    except DeviceError as error:
        if is_dead_session(error):
            return False
        raise


def open_bridge(root, state=None):
    """A bridge that reuses the saved MCP session id, or starts a new one."""
    session_id = state["mcpSessionId"] if state else str(uuid.uuid4())
    return Bridge(session_id)


def find_device_uuid(data):
    """The device identifier in a session reply, or None."""
    for key in ("deviceUUID", "deviceUdid", "deviceIdentifier", "udid"):
        if isinstance(data.get(key), str):
            return data[key]
    return None


# MARK: Commands

def cmd_doctor(argv):
    """Check the setup, print one PASS or FAIL line each, and exit 1 on any FAIL."""
    failures = 0

    def report(ok, text):
        nonlocal failures
        if not ok:
            failures += 1
        say("%s  %s" % ("PASS" if ok else "FAIL", text))

    try:
        root = checkout_root()
        project = find_project(root)
        report(True, "checkout %s" % root)
        report(True, "project %s" % os.path.basename(project))
    except DeviceError as error:
        report(False, "checkout: %s" % error)
        sys.exit(1)

    developer = subprocess.run(["xcode-select", "-p"], capture_output=True, text=True).stdout.strip()
    state = load_state(root)
    try:
        with open_bridge(root, state) as bridge:
            report(True, "mcpbridge %s (Xcode at %s)" % (bridge.path, developer))
            tools = bridge.list_tools()
            report(True, "server answers tools/list (%d tools)" % len(tools))
            names = {tool["name"] for tool in tools}
            missing = [name for name in DEVICE_TOOLS if name not in names]
            report(not missing, "tools/list has the five DeviceInteraction tools" +
                   (" (missing: %s)" % ", ".join(missing) if missing else ""))
            booted_report(report)
            if state is None:
                report(True, "no saved session (run `start`)")
            else:
                try:
                    alive = session_alive(bridge, state)
                    report(alive, "saved session %s %s" % (
                        state["sessionName"],
                        "is valid" if alive else "is dead. Run `start`, which starts fresh"))
                except DeviceError as error:
                    report(False, "saved session check failed: %s" % error)
    except DeviceError as error:
        report(False, "bridge: %s" % error)
        log_failure("doctor %s" % error)
    if failures:
        log_failure("doctor: %d check(s) failed" % failures)
        sys.exit(1)


def booted_report(report):
    """Report the booted simulators through `report`."""
    done = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "booted", "--json"], capture_output=True, text=True
    )
    if done.returncode != 0:
        report(False, "simctl cannot list devices: %s" % done.stderr.strip())
        return
    booted = []
    for runtime, devices in json.loads(done.stdout)["devices"].items():
        for device in devices:
            booted.append("%s %s (%s)" % (device["udid"], device["name"], runtime.split(".")[-1]))
    report(True, "booted devices: %s" % ("; ".join(booted) if booted else "none"))


def cmd_syntax(argv):
    """Print the live input schema of the five device tools."""
    with Bridge(str(uuid.uuid4())) as bridge:
        for tool in bridge.list_tools():
            if tool["name"] in DEVICE_TOOLS:
                say("## %s\n%s" % (tool["name"], tool.get("description", "")))
                say(json.dumps(tool.get("inputSchema", {}), indent=1))


def cmd_start(argv):
    """Open the workspace, start a session and save its state."""
    root = checkout_root()
    project = find_project(root)
    old = load_state(root)
    if old is not None:
        with open_bridge(root, old) as bridge:
            try:
                alive = session_alive(bridge, old)
            except DeviceError as error:
                say("saved session could not be checked (%s); starting fresh" % error)
                alive = False
            if alive:
                say("closing the saved session %s first" % old["sessionName"])
                try:
                    bridge.call("DeviceInteractionEndSession", {"interactionSessionKey": old["interactionSessionKey"]})
                except DeviceError as error:
                    say("could not close it (%s); starting fresh" % error)
            else:
                say("saved session is dead; starting fresh")
        os.remove(state_path(root))

    name = "%s-%s" % (argv[0] if argv else "agent", uuid.uuid4().hex[:8])
    session_id = str(uuid.uuid4())
    with Bridge(session_id) as bridge:
        say("opening %s" % os.path.basename(project))
        opened = bridge.call("XcodeOpenWorkspace", {"path": project})
        workspace = opened["workspaceIdentifier"]
        say("starting session %s" % name)
        data = bridge.call(
            "DeviceInteractionStartWorkspaceSession",
            {"sessionIdentifier": name, "workspaceIdentifier": workspace},
            BUILD_TIMEOUT,
        )
    device = find_device_uuid(data)
    key = data.get("interactionSessionKey")
    if not key or not device:
        raise DeviceError("the server did not return a session key and device UUID: %s" % json.dumps(data))
    save_state(root, {
        "checkoutRoot": root,
        "sessionName": name,
        "mcpSessionId": session_id,
        "interactionSessionKey": key,
        "deviceUUID": device,
        "server": data,
    })
    say("session %s" % name)
    say("device %s" % device)


def cmd_run(argv):
    """Build, install and launch the app, passing the arguments to it."""
    root = checkout_root()
    state = require_state(root)
    arguments = {"interactionSessionKey": state["interactionSessionKey"]}
    if argv:
        arguments["commandLineArguments"] = ["$(inherited)"] + argv
    with open_bridge(root, state) as bridge:
        # A workspace identifier belongs to the bridge that issued it, so ask again.
        opened = bridge.call("XcodeOpenWorkspace", {"path": find_project(root)})
        arguments["workspaceIdentifier"] = opened["workspaceIdentifier"]
        say("building, installing and launching (can take minutes)")
        started = time.monotonic()
        data = bridge.call("DeviceInteractionInstallAndRun", arguments, BUILD_TIMEOUT)
    say("done in %ds" % (time.monotonic() - started))
    say(json.dumps(data, indent=2))


def cmd_do(argv):
    """Send one interaction command, then print the capture paths."""
    root = checkout_root()
    state = require_state(root)
    arguments = {"interactSessionKey": state["interactionSessionKey"]}
    if argv and argv[0]:
        arguments["interactionCommand"] = argv[0]
    with open_bridge(root, state) as bridge:
        data = bridge.call("DeviceInteractionSynthesize", arguments)
    for key in ("screenshotPath", "thumbnailScreenshotPath", "hierarchyPath", "logsPath"):
        say("%s: %s" % (key, data.get(key)))
    if "applicationState" in data:
        say("applicationState: %s" % json.dumps(data["applicationState"]))


def cmd_shot(argv):
    """Save a native screenshot of the session's device to the given path."""
    if len(argv) != 1:
        raise DeviceError("usage: shot <path.png>")
    state = require_state(checkout_root())
    path = os.path.abspath(argv[0])
    done = subprocess.run(
        ["xcrun", "simctl", "io", state["deviceUUID"], "screenshot", path],
        capture_output=True, text=True,
    )
    if done.returncode != 0:
        raise DeviceError("simctl screenshot failed: %s" % done.stderr.strip())
    say("screenshot: %s" % path)


def cmd_end(argv):
    """Close the session and delete the saved state."""
    root = checkout_root()
    state = require_state(root)
    with open_bridge(root, state) as bridge:
        try:
            bridge.call("DeviceInteractionEndSession", {"interactionSessionKey": state["interactionSessionKey"]})
            say("session %s closed" % state["sessionName"])
        except DeviceError as error:
            if not is_dead_session(error):
                raise
            say("the server had already dropped the session")
    os.remove(state_path(root))


def cmd_status(argv):
    """Print the saved state, or "no session"."""
    state = load_state(checkout_root())
    say(json.dumps(state, indent=2) if state else "no session")


COMMANDS = {
    "doctor": cmd_doctor,
    "syntax": cmd_syntax,
    "start": cmd_start,
    "run": cmd_run,
    "do": cmd_do,
    "shot": cmd_shot,
    "end": cmd_end,
    "status": cmd_status,
}
NEEDS_SESSION = {"run", "do", "end"}


def main():
    """Run the named command and turn failures into one line plus an exit code."""
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        print(__doc__)
        sys.exit(2)
    command = sys.argv[1]
    try:
        COMMANDS[command](sys.argv[2:])
    except DeviceError as error:
        message = str(error)
        if command in NEEDS_SESSION and is_dead_session(error):
            message += ". The session is dead: run `start` to begin a new one"
        log_failure("%s: %s" % (command, message))
        say("failed: %s" % message)
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(130)
    except Exception as error:
        log_failure("%s: unexpected %s: %s" % (command, type(error).__name__, error))
        say("failed: unexpected %s: %s" % (type(error).__name__, error))
        sys.exit(1)


main()

