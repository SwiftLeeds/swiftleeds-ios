import plistlib
import re
import sys
from pathlib import Path

import xcproj

project_path = Path("SwiftLeeds.xcodeproj/project.xcproj")
if not project_path.exists():
    print("::error::Found no SwiftLeeds.xcodeproj/project.xcproj to check")
    sys.exit(1)

APP_GROUPS_KEY = "com.apple.security.application-groups"
# ConferenceConfig calls fatalError when this key is missing from Bundle.main,
# and an extension carries its own bundle.
GROUP_NAME_KEY = "AppGroupIdentifier"

# Horizontal space only: \s would let an empty value swallow the next line.
setting = re.compile(r"^[ \t]*(?P<key>[A-Z_]+)[ \t]*=[ \t]*(?P<value>[^ \t\n].*?)[ \t]*$", re.MULTILINE)


def read_setting(path, key):
    for match in setting.finditer(path.read_text()):
        if match.group("key") == key:
            return match.group("value")
    return None


def read_app_groups(path):
    with path.open("rb") as handle:
        return plistlib.load(handle).get(APP_GROUPS_KEY)


checked = 0
failed = False
agreed = []
project = xcproj.load(project_path)

for target in project.get("targets", []):
    settings = target.get("build-settings", {})
    for configuration in target.get("specialized-configurations", []):
        name = configuration["name"]
        where = f"{target['name']} / {name}"

        if "file" not in configuration:
            continue
        xcconfig = Path(configuration["file"])
        if xcconfig.parent != Path("Configuration") or not xcconfig.exists():
            print(f"::error::{where} names an xcconfig that is not in Configuration/")
            failed = True
            continue

        # The app target sets its entitlements in the xcconfig, not in the project.
        granted = xcproj.setting(settings, "CODE_SIGN_ENTITLEMENTS", name) or read_setting(
            xcconfig, "CODE_SIGN_ENTITLEMENTS"
        )
        if granted is None:
            continue
        signed_with = Path(granted)
        if not signed_with.exists():
            print(f"::error::{where} signs with {signed_with}, which does not exist")
            failed = True
            continue

        declared = read_app_groups(signed_with)
        # An App Clip declares no app group at all, which is not a mismatch.
        if not declared:
            continue

        expected = read_setting(xcconfig, "APP_GROUP_IDENTIFIER")
        if expected is None:
            print(f"::error::{xcconfig} sets no APP_GROUP_IDENTIFIER, but {signed_with} declares one")
            failed = True
            continue

        plist = xcproj.setting(settings, "INFOPLIST_FILE", name) or read_setting(xcconfig, "INFOPLIST_FILE")
        if plist is None or not Path(plist).exists():
            print(f"::error::{where} grants an app group but names no Info.plist that exists")
            failed = True
            continue
        with Path(plist).open("rb") as handle:
            if GROUP_NAME_KEY not in plistlib.load(handle):
                print(f"::error::{where} is granted {expected}, but {plist} sets no {GROUP_NAME_KEY}")
                failed = True
                continue

        checked += 1
        if expected in declared:
            agreed.append(f"{where}: {signed_with} grants {expected}, {plist} names it")
        else:
            print(
                f"::error::{where} writes to {expected} "
                f"but {signed_with} grants only {', '.join(declared)}"
            )
            failed = True

for line in sorted(agreed):
    print(line)

# Zero pairs means the format moved, not that the project is clean.
if checked == 0:
    print("::error::Found no configuration pairing an xcconfig with an entitlements file")
    failed = True

# Both brands build the same targets, so a literal pins one of them.
literal = re.compile(r"\"group\.[^\"]*\"")
for source in sorted(Path().glob("**/*.swift")):
    # Build output holds third-party sources.
    if any(part == "build" or part.startswith(".build") for part in source.parts):
        continue
    for number, line in enumerate(source.read_text().splitlines(), start=1):
        if literal.search(line):
            print(f"::error::{source}:{number} hardcodes an app group; read ConferenceConfig.appGroupIdentifier")
            failed = True

sys.exit(1 if failed else 0)
