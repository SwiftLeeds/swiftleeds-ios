#!/usr/bin/env python3
"""Checks that each local package links only what its role allows.

A package's role comes from its folder under Packages/: Kit, Feature, FeatureUI
or DesignSystem. The matrix says which role may link which, and which third-party
packages and plugins each role may use. Test targets are not judged.

BASELINE lists the violations that exist today. A row that no longer matches
anything is an error, so the list can only shrink.

Run locally: python3 .github/scripts/check-dependency-matrix.py
"""
import json
import os
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path

# Through a pipe, as on CI, Python would hold these lines until exit.
sys.stdout.reconfigure(line_buffering=True)

PACKAGE_GLOBS = ["Packages/*/*/Package.swift", "SwiftLeedsPackage/Package.swift"]
ROOT = Path.cwd()
SCRATCH_PATH = ROOT / ".build-shared"

KIT, FEATURE, FEATURE_UI, UI_FOUNDATION = "kit", "feature", "feature UI", "UI foundation"

ROLE_OF_FOLDER = {
    "Kit": KIT,
    "Feature": FEATURE,
    "FeatureUI": FEATURE_UI,
    "DesignSystem": UI_FOUNDATION,
}

# A package outside Packages/ has no folder to read a role from.
EXPLICIT_ROLES = {
    # Holds the UIAssets catalogs, which every screen draws from.
    "SwiftLeedsPackage": UI_FOUNDATION,
}

# The roles a package may link, by its own role. A feature UI also gets its
# own feature, which is worked out from its name.
MAY_LINK = {
    KIT: {KIT},
    FEATURE: {KIT},
    FEATURE_UI: {UI_FOUNDATION},
    UI_FOUNDATION: {UI_FOUNDATION},
}

UNIVERSAL_THIRD_PARTY = {"swift-dependencies"}

UI_ROLES = {FEATURE_UI, UI_FOUNDATION}

# Third-party libraries the roles that draw screens may link.
UI_LIBRARIES = {
    "swift-sharing",
    "swiftui-cached-async-image",
    "readabilitymodifier",
    "sfsafesymbols",
}

# Build plugins, for the same roles.
UI_PLUGINS = {"swiftgenplugin"}

INFRASTRUCTURE_SUFFIX = "Infrastructure"
TEST_SUPPORT_SUFFIX = "TestSupport"

# Violations that exist today, keyed by (target, product). Remove a row when
# that package receives its URLs from the app instead.
BASELINE = {
    ("SettingsUI", "NetworkKit"): "builds the code of conduct link from the API base URL",
    ("AboutUI", "NetworkKit"): "builds website links from the API base URL",
}

# Set 5% below the count of local, third-party and plugin edges on a clean run
# (rounded down). A parse that quietly finds nothing reads as clean, so a low
# count must fail.
MIN_EDGES = 47

log_folder = Path(os.environ.get("RUNNER_TEMP") or tempfile.gettempdir())
log_path = log_folder / "dependency-matrix.log"

failed = False
errors = []


def report(message):
    """Print an error whose first line is the annotation, and keep it for the log."""
    global failed
    failed = True
    first, *rest = message.strip().splitlines() or [""]
    print(f"::error::{first}")
    for line in rest:
        print(line)
    errors.append(f"{datetime.now().isoformat()} {message.strip()}")


def finish(packages_read, edges, known_count):
    """Write the log if anything failed, print the summary and exit."""
    if errors:
        with log_path.open("a") as handle:
            handle.write("\n".join(errors) + "\n")
        print(f"Errors are also in {log_path}")
    print(f"Read {packages_read} packages, judged {edges} edges, {known_count} known violations")
    sys.exit(1 if failed else 0)


def dump_package(directory):
    """Return the manifest of the package in a folder as JSON, or None after reporting why not."""
    command = [
        "swift", "package", "dump-package",
        "--package-path", str(directory),
        "--scratch-path", str(SCRATCH_PATH),
    ]
    try:
        completed = subprocess.run(command, capture_output=True, text=True)
    except OSError as error:
        report(f"{directory.name}: could not run swift: {error}")
        return None
    if completed.returncode != 0:
        report(f"{directory.name}: swift package dump-package failed\n{completed.stderr}")
        return None
    try:
        return json.loads(completed.stdout)
    except json.JSONDecodeError as error:
        report(f"{directory.name}: dump-package printed unreadable JSON: {error}")
        return None


manifests = sorted(path for pattern in PACKAGE_GLOBS for path in ROOT.glob(pattern))
if not manifests:
    report("Found no packages, so this check is broken")
    finish(0, 0, 0)

dumps = {}
directories = {}
for manifest in manifests:
    directory = manifest.parent
    print(f"reading {directory.name}")
    dump = dump_package(directory)
    if dump is not None:
        dumps[directory.name] = dump
        directories[directory.name] = directory


def role_of(name, directory):
    """Return the package's role from its folder, or None after reporting a mismatch."""
    if name in EXPLICIT_ROLES:
        return EXPLICIT_ROLES[name]
    role = ROLE_OF_FOLDER.get(directory.parent.name)
    if role is None:
        report(f"{name}: folder {directory.parent.name} has no role in the matrix")
        return None
    expected = {
        KIT: name.endswith("Kit"),
        FEATURE: name.endswith("Feature"),
        FEATURE_UI: name.endswith("UI"),
        UI_FOUNDATION: name.startswith("UI"),
    }[role]
    if not expected:
        report(f"{name}: name does not fit its folder {directory.parent.name}, which holds a {role}")
        return None
    return role


roles = {name: role_of(name, directories[name]) for name in dumps}
by_identity = {name.lower(): name for name in dumps}


def local_dependencies(dump):
    """Map each local dependency's identity to its package name, or None when it lies outside the checked set."""
    found = {}
    for entry in dump["dependencies"]:
        for local in entry.get("fileSystem", []):
            identity = local["identity"]
            found[identity] = by_identity.get(identity)
    return found


def remote_identities(dump):
    """Identities of the remote (source control) dependencies."""
    return {
        remote["identity"]
        for entry in dump["dependencies"]
        for remote in entry.get("sourceControl", [])
    }


def third_party_allowed(role, identity):
    """Whether a package of this role may link this third-party library."""
    if identity in UNIVERSAL_THIRD_PARTY or role == KIT:
        return True
    return role in UI_ROLES and identity in UI_LIBRARIES


def plugin_allowed(role, identity):
    """Whether a package of this role may use this third-party build plugin."""
    if role == KIT:
        return True
    return role in UI_ROLES and identity in UI_PLUGINS


def judge(package, role, target, product, linked):
    """Reasons the edge is forbidden, or an empty list."""
    reasons = []
    linked_role = roles.get(linked)
    if linked_role is None:
        return reasons
    allowed = linked_role in MAY_LINK[role]
    if role == FEATURE_UI and linked == package.removesuffix("UI") + "Feature":
        allowed = True
    if not allowed:
        reasons.append(f"a {role} may not link a {linked_role} ({linked})")
    if role == FEATURE_UI and product.endswith(INFRASTRUCTURE_SUFFIX):
        reasons.append(f"a {role} may not link {product}, an infrastructure product")
    if product.endswith(TEST_SUPPORT_SUFFIX) and not target.endswith(TEST_SUPPORT_SUFFIX):
        reasons.append(f"{target} is not test support, so it may not link {product}")
    return reasons


edges_judged = 0
known = []
matched_baseline = set()


def report_violations(package, role, target, product, linked):
    """Report each rule a local edge breaks, or note it as a known violation."""
    for reason in judge(package, role, target, product, linked):
        key = (target, product)
        if key in BASELINE:
            matched_baseline.add(key)
            known.append(f"{target} -> {product}: {reason} (known: {BASELINE[key]})")
        else:
            report(f"{package}/{target} links {product} from {linked}: {reason}")


for package in sorted(dumps):
    dump = dumps[package]
    role = roles[package]
    if role is None:
        continue
    local = local_dependencies(dump)
    remote = remote_identities(dump)
    own_targets = {target["name"] for target in dump["targets"]}
    package_edges = 0
    third_party_edges = 0

    for target in dump["targets"]:
        if target["type"] == "test":
            continue
        for dependency in target["dependencies"]:
            kind = next(iter(dependency), None)
            if kind is None or len(dependency) != 1:
                report(f"{package}/{target['name']}: unreadable dependency {dependency}")
                continue
            details = dependency[kind]
            linked = None
            product = None

            if kind == "target":
                continue
            elif kind == "byName":
                product = details[0]
                if product in own_targets:
                    continue
                for name in local.values():
                    if name and any(p["name"] == product for p in dumps[name]["products"]):
                        linked = name
                        break
                if linked is None and product.lower() in remote:
                    third_party_edges += 1
                    edges_judged += 1
                    if not third_party_allowed(role, product.lower()):
                        report(f"{package}/{target['name']} links {product} from third-party {product.lower()}: a {role} may not")
                    continue
                if linked is None:
                    report(f"{package}/{target['name']}: {product} is not a target here or a product of a local package")
                    continue
            elif kind == "product":
                product, package_name = details[0], details[1]
                identity = package_name.lower()
                if identity in local:
                    linked = local[identity]
                    if linked is None:
                        report(f"{package}/{target['name']}: {product} comes from a local package outside the checked set")
                        continue
                elif identity in remote:
                    third_party_edges += 1
                    edges_judged += 1
                    if not third_party_allowed(role, identity):
                        report(f"{package}/{target['name']} links {product} from third-party {identity}: a {role} may not")
                    continue
                else:
                    report(f"{package}/{target['name']}: {product} names package {package_name}, which is not a dependency")
                    continue
            else:
                report(f"{package}/{target['name']}: dependency kind {kind} is new; the manifest format moved")
                continue

            package_edges += 1
            edges_judged += 1
            report_violations(package, role, target["name"], product, linked)

        for usage in target.get("pluginUsages", []):
            plugin, plugin_package = usage["plugin"][0], usage["plugin"][1]
            if plugin_package is None:
                continue
            identity = plugin_package.lower()
            if identity in local:
                if local[identity] is None:
                    report(f"{package}/{target['name']}: plugin {plugin} comes from a local package outside the checked set")
                    continue
                package_edges += 1
                edges_judged += 1
                report_violations(package, role, target["name"], plugin, local[identity])
            elif identity in remote:
                third_party_edges += 1
                edges_judged += 1
                if not plugin_allowed(role, identity):
                    report(f"{package}/{target['name']} uses plugin {plugin} from third-party {identity}: a {role} may not")
            else:
                report(f"{package}/{target['name']}: plugin {plugin} names package {plugin_package}, which is not a dependency")

    print(f"{package}: {package_edges} local, {third_party_edges} third-party edges")

for line in known:
    print(f"known violation: {line}")

# A package that failed to dump would leave its rows unmatched, so stale rows
# are only judged when every package was read.
if len(dumps) == len(manifests):
    for target, product in sorted(set(BASELINE) - matched_baseline):
        report(f"Baseline row {target} -> {product} no longer applies; delete it from BASELINE")

if edges_judged < MIN_EDGES:
    report(f"Judged {edges_judged} edges, under the floor of {MIN_EDGES}, so this check is broken")

finish(len(dumps), edges_judged, len(known))
