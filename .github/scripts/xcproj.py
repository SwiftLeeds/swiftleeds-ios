# Reads an Xcode project in the JSON format Xcode 27.2 writes (project.xcproj).
import json
from pathlib import Path


class DuplicateKey(ValueError):
    pass


def _reject_duplicates(pairs):
    keys = [key for key, _ in pairs]
    repeated = sorted({key for key in keys if keys.count(key) > 1})
    if repeated:
        # json.loads keeps the last of two equal keys and says nothing, so a merge that
        # repeats a key would drop the first value silently.
        raise DuplicateKey(f"repeats the key {', '.join(repeated)}")
    return dict(pairs)


def _without_trailing_commas(text):
    # Xcode writes a comma after the last item of every array and object, which JSON
    # does not allow. Drop only a comma that is outside a string and comes before a
    # closing bracket.
    kept = []
    in_string = False
    escaped = False
    for index, character in enumerate(text):
        if in_string:
            kept.append(character)
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == '"':
                in_string = False
            continue
        if character == '"':
            in_string = True
        elif character == ",":
            rest = text[index + 1:].lstrip()
            if rest[:1] in ("]", "}"):
                continue
        kept.append(character)
    return "".join(kept)


# Raises DuplicateKey when an object repeats a key, and json.JSONDecodeError when the
# text is not JSON once the trailing commas are gone.
def load(path):
    text = Path(path).read_text()
    return json.loads(_without_trailing_commas(text), object_pairs_hook=_reject_duplicates)


# A setting written for one configuration, KEY[config=<name>], wins over plain KEY.
def setting(settings, key, configuration):
    return settings.get(f"{key}[config={configuration}]", settings.get(key))


# Every file entry in the file tree, with groups flattened.
def files(entries):
    for entry in entries:
        if entry.get("kind") == "group":
            yield from files(entry.get("children", []))
        else:
            yield entry
