# Checks that every configuration of a target that compiles ConferenceConfig.swift
# shows its brand's APP_DISPLAY_NAME as CFBundleDisplayName.
import plistlib
import re
import sys
from pathlib import Path

import xcproj

project_path = Path("SwiftLeeds.xcodeproj/project.xcproj")
if not project_path.exists():
    print("::error::Found no SwiftLeeds.xcodeproj/project.xcproj to check")
    sys.exit(1)

SOURCE_FILE = "ConferenceConfig.swift"
# ConferenceConfig calls fatalError when this key is missing or empty in Bundle.main,
# and the app, the App Clip and the widget extension each carry their own bundle.
NAME_KEY = "CFBundleDisplayName"
BRAND_KEY = "APP_DISPLAY_NAME"

# Horizontal space only: \s would let an empty value swallow the next line.
setting = re.compile(r"^[ \t]*(?P<key>[A-Z_]+)[ \t]*=[ \t]*(?P<value>[^\n]*?)[ \t]*$", re.MULTILINE)
reference = re.compile(r"\$\((?P<name>\w+)\)|\$\{(?P<braced>\w+)\}")


def read_settings(path):
    return {match.group("key"): match.group("value") for match in setting.finditer(path.read_text())}


# Resolves against the xcconfig only. Xcode also reads target and project settings,
# so an APP_DISPLAY_NAME set in the project file would be missed.
def resolve(value, settings):
    def substitute(match):
        return settings.get(match.group("name") or match.group("braced"), match.group(0))

    return reference.sub(substitute, value)


project = xcproj.load(project_path)

# Select by what compiles ConferenceConfig, not by which targets have an xcconfig.
compiling = set()
for entry in xcproj.files(project.get("files", [])):
    if Path(entry.get("path", "")).name != SOURCE_FILE:
        continue
    for member in entry.get("target-membership", []):
        if isinstance(member, str) and member.endswith("/compile-sources"):
            compiling.add(member.removesuffix("/compile-sources"))

checked = 0
failed = False
agreed = []

for target in project.get("targets", []):
    if target["name"] not in compiling:
        continue
    target_settings = target.get("build-settings", {})
    for configuration in target.get("specialized-configurations", []):
        name = configuration["name"]
        checked += 1
        where = f"{target['name']} / {name}"

        xcconfig = Path(configuration["file"]) if "file" in configuration else None
        if xcconfig is None or xcconfig.parent != Path("Configuration") or not xcconfig.exists():
            print(f"::error::{where} names no xcconfig in Configuration/")
            failed = True
            continue
        settings = read_settings(xcconfig)
        expected = settings.get(BRAND_KEY)
        if not expected:
            print(f"::error::{where} uses {xcconfig.name}, which sets no {BRAND_KEY}")
            failed = True
            continue

        shown = xcproj.setting(target_settings, f"INFOPLIST_KEY_{NAME_KEY}", name)
        if shown is not None:
            if xcproj.setting(target_settings, "GENERATE_INFOPLIST_FILE", name) != "YES":
                # Xcode ignores INFOPLIST_KEY_ settings unless it generates the plist.
                print(f"::error::{where} sets INFOPLIST_KEY_{NAME_KEY} but not GENERATE_INFOPLIST_FILE = YES")
                failed = True
                continue
        else:
            plist = xcproj.setting(target_settings, "INFOPLIST_FILE", name) or settings.get("INFOPLIST_FILE")
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
    print(f"::error::Found no target that compiles {SOURCE_FILE}")
    failed = True

sys.exit(1 if failed else 0)
