import plistlib
import re
import sys
from pathlib import Path

project = Path("SwiftLeeds.xcodeproj/project.pbxproj")
if not project.exists():
    print("::error::Found no SwiftLeeds.xcodeproj/project.pbxproj to check")
    sys.exit(1)

APP_GROUPS_KEY = "com.apple.security.application-groups"
# ConferenceConfig reads this key from Bundle.main and calls fatalError when it
# is absent. An extension carries its own bundle, so every target that is
# granted a group needs its own copy of the name.
GROUP_NAME_KEY = "AppGroupIdentifier"

# A build configuration block opens at two tabs and closes at two tabs. Its
# base xcconfig supplies APP_GROUP_IDENTIFIER, and either the block or that
# same xcconfig supplies the entitlements file the configuration signs with.
block = re.compile(
    r"^\t\t(?P<id>[0-9A-F]{24}) /\* (?P<name>[^*]+?) \*/ = \{\n(?P<body>.*?)^\t\t\};$",
    re.MULTILINE | re.DOTALL,
)
owner = re.compile(r"Build configuration list for (?P<kind>\w+) \"(?P<target>[^\"]+)\"")
member = re.compile(r"^\t\t\t\t(?P<id>[0-9A-F]{24}) /\*", re.MULTILINE)
base_config = re.compile(r"baseConfigurationReference = [0-9A-F]{24} /\* (?P<file>[^*]+?) \*/;")
# Anchored to the start of the line: GENERATE_INFOPLIST_FILE ends in the name
# INFOPLIST_FILE, and an unanchored search reads its YES as a file path.
entitlements = re.compile(r"^\s*CODE_SIGN_ENTITLEMENTS = \"?(?P<path>[^\";]+?)\"?;", re.MULTILINE)
info_plist = re.compile(r"^\s*INFOPLIST_FILE = \"?(?P<path>[^\";]+?)\"?;", re.MULTILINE)
setting = re.compile(r"^\s*(?P<key>[A-Z_]+)\s*=\s*(?P<value>.+?)\s*$", re.MULTILINE)

xcconfigs = {path.name: path for path in Path("Configuration").glob("*.xcconfig")}


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
blocks = list(block.finditer(project.read_text()))

# A configuration knows its settings but not its target. The configuration list
# that holds it names the target in its own comment, so map the two together.
# Only a target signs and only a target carries an Info.plist, so the
# project-level list is skipped: every target has its own block anyway.
target_of = {}
for match in blocks:
    named = owner.search(match.group("name"))
    if named is None or named.group("kind") != "PBXNativeTarget":
        continue
    for listed in member.finditer(match.group("body")):
        target_of[listed.group("id")] = named.group("target")

for match in blocks:
    body = match.group("body")
    if "isa = XCBuildConfiguration;" not in body:
        continue
    target = target_of.get(match.group("id"))
    if target is None:
        continue
    where = f"{target} / {match.group('name')}"

    base = base_config.search(body)
    if base is None:
        continue
    xcconfig = xcconfigs.get(base.group("file"))
    if xcconfig is None:
        print(f"::error::{where} names an xcconfig that is not in Configuration/")
        failed = True
        continue

    found = entitlements.search(body)
    # An xcconfig line carries no trailing semicolon, so it needs its own read.
    granted = found.group("path") if found else read_setting(xcconfig, "CODE_SIGN_ENTITLEMENTS")
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

    # Being granted the group is half of it. The target also has to be able to
    # read the group's name, or it traps in ConferenceConfig at launch.
    named = info_plist.search(body)
    plist = named.group("path") if named else read_setting(xcconfig, "INFOPLIST_FILE")
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

# The app group belongs to the configuration. A literal in Swift pins one brand
# into a target both brands build, which is how the KotlinLeeds widget read a
# suite it is not entitled to and silently showed nothing.
literal = re.compile(r"\"group\.[^\"]*\"")
for source in sorted(Path().glob("**/*.swift")):
    # Build output holds third-party sources, which are nobody's to fix here.
    if any(part == "build" or part.startswith(".build") for part in source.parts):
        continue
    for number, line in enumerate(source.read_text().splitlines(), start=1):
        if literal.search(line):
            print(f"::error::{source}:{number} hardcodes an app group; read ConferenceConfig.appGroupIdentifier")
            failed = True

sys.exit(1 if failed else 0)
