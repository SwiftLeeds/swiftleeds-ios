# Checks that every configuration of a target that compiles ConferenceConfig.swift
# shows its brand's APP_DISPLAY_NAME as CFBundleDisplayName.
import plistlib
import re
import sys
from pathlib import Path

project = Path("SwiftLeeds.xcodeproj/project.pbxproj")
if not project.exists():
    print("::error::Found no SwiftLeeds.xcodeproj/project.pbxproj to check")
    sys.exit(1)

SOURCE_FILE = "ConferenceConfig.swift in Sources"
# ConferenceConfig calls fatalError when this key is missing or empty in Bundle.main,
# and the app, the App Clip and the widget extension each carry their own bundle.
NAME_KEY = "CFBundleDisplayName"
BRAND_KEY = "APP_DISPLAY_NAME"

block = re.compile(
    r"^\t\t(?P<id>[0-9A-F]{24}) /\* (?P<name>[^*]+?) \*/ = \{\n(?P<body>.*?)^\t\t\};$",
    re.MULTILINE | re.DOTALL,
)
owner = re.compile(r"Build configuration list for (?P<kind>\w+) \"(?P<target>[^\"]+)\"")
member = re.compile(r"^\t\t\t\t(?P<id>[0-9A-F]{24}) /\*", re.MULTILINE)
compiles = re.compile(
    rf"^\t\t(?P<id>[0-9A-F]{{24}}) /\* {re.escape(SOURCE_FILE)} \*/ = \{{isa = PBXBuildFile;",
    re.MULTILINE,
)
config_list = re.compile(r"buildConfigurationList = (?P<id>[0-9A-F]{24}) /\*")
base_config = re.compile(r"baseConfigurationReference = [0-9A-F]{24} /\* (?P<file>[^*]+?) \*/;")
# Anchored: GENERATE_INFOPLIST_FILE ends in INFOPLIST_FILE, so an unanchored
# search reads its YES as a file path.
info_plist = re.compile(r"^\s*INFOPLIST_FILE = \"?(?P<path>[^\";]+?)\"?;", re.MULTILINE)
generates = re.compile(r"^\s*GENERATE_INFOPLIST_FILE = YES;", re.MULTILINE)
# A quoted value may be empty or hold $(...), a bare one is a single word.
display_name = re.compile(
    rf"^\s*INFOPLIST_KEY_{NAME_KEY} = (?:\"(?P<quoted>[^\"]*)\"|(?P<bare>[^\";\s]+));",
    re.MULTILINE,
)
# Horizontal space only: \s would let an empty value swallow the next line.
setting = re.compile(r"^[ \t]*(?P<key>[A-Z_]+)[ \t]*=[ \t]*(?P<value>[^\n]*?)[ \t]*$", re.MULTILINE)
reference = re.compile(r"\$\((?P<name>\w+)\)|\$\{(?P<braced>\w+)\}")

xcconfigs = {path.name: path for path in Path("Configuration").glob("*.xcconfig")}


def read_settings(path):
    return {match.group("key"): match.group("value") for match in setting.finditer(path.read_text())}


# Resolves against the xcconfig only. Xcode also reads target and project settings,
# so an APP_DISPLAY_NAME set in the project file would be missed.
def resolve(value, settings):
    def substitute(match):
        return settings.get(match.group("name") or match.group("braced"), match.group(0))

    return reference.sub(substitute, value)


blocks = list(block.finditer(project.read_text()))
source_ids = {match.group("id") for match in compiles.finditer(project.read_text())}

phases = {
    match.group("id")
    for match in blocks
    if "isa = PBXSourcesBuildPhase;" in match.group("body")
    and any(listed.group("id") in source_ids for listed in member.finditer(match.group("body")))
}

# Select by what compiles ConferenceConfig, not by which targets have an xcconfig.
list_of = {}
for match in blocks:
    body = match.group("body")
    if "isa = PBXNativeTarget;" not in body:
        continue
    if not any(listed.group("id") in phases for listed in member.finditer(body)):
        continue
    found = config_list.search(body)
    if found:
        list_of[found.group("id")] = None

target_of = {}
for match in blocks:
    if match.group("id") not in list_of:
        continue
    named = owner.search(match.group("name"))
    for listed in member.finditer(match.group("body")):
        target_of[listed.group("id")] = named.group("target") if named else match.group("id")

checked = 0
failed = False
agreed = []

for match in blocks:
    body = match.group("body")
    if "isa = XCBuildConfiguration;" not in body:
        continue
    target = target_of.get(match.group("id"))
    if target is None:
        continue
    checked += 1
    where = f"{target} / {match.group('name')}"

    base = base_config.search(body)
    xcconfig = xcconfigs.get(base.group("file")) if base else None
    if xcconfig is None:
        print(f"::error::{where} names no xcconfig in Configuration/")
        failed = True
        continue
    settings = read_settings(xcconfig)
    expected = settings.get(BRAND_KEY)
    if not expected:
        print(f"::error::{where} uses {xcconfig.name}, which sets no {BRAND_KEY}")
        failed = True
        continue

    named = display_name.search(body)
    if named:
        shown = named.group("quoted") if named.group("quoted") is not None else named.group("bare")
        if not generates.search(body):
            # Xcode ignores INFOPLIST_KEY_ settings unless it generates the plist.
            print(f"::error::{where} sets INFOPLIST_KEY_{NAME_KEY} but not GENERATE_INFOPLIST_FILE = YES")
            failed = True
            continue
    else:
        file = info_plist.search(body)
        plist = file.group("path") if file else settings.get("INFOPLIST_FILE")
        if plist is None or not Path(plist).exists():
            print(f"::error::{where} sets no INFOPLIST_KEY_{NAME_KEY} and names no Info.plist that exists")
            failed = True
            continue
        with Path(plist).open("rb") as handle:
            shown = plistlib.load(handle).get(NAME_KEY)
        if shown is None:
            print(f"::error::{where} sets no INFOPLIST_KEY_{NAME_KEY}, and {plist} sets no {NAME_KEY}")
            failed = True
            continue

    if not shown:
        print(f"::error::{where} shows an empty {NAME_KEY}")
        failed = True
        continue

    resolved = resolve(shown, settings)
    if "$" in resolved:
        print(f"::error::{where} shows {shown}, which {xcconfig.name} does not resolve")
        failed = True
        continue

    if resolved == expected:
        agreed.append(f"{where}: {resolved}")
    else:
        print(f"::error::{where} shows {resolved}, but {xcconfig.name} names the brand {expected}")
        failed = True

for line in sorted(agreed):
    print(line)

# Zero configurations means the format moved, not that the project is clean.
if checked == 0:
    print(f"::error::Found no target that compiles {SOURCE_FILE.removesuffix(' in Sources')}")
    failed = True

sys.exit(1 if failed else 0)
