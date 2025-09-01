#!/usr/bin/env python3
"""Basic validation for CACAO-style YAML playbooks."""
import sys
import pathlib
import yaml

REQUIRED_TOP_LEVEL = {"id", "name", "description", "start", "actions"}
REQUIRED_ACTION_KEYS = {"description", "command"}


def validate_playbook(path: pathlib.Path) -> None:
    with path.open() as f:
        data = yaml.safe_load(f)
    missing = REQUIRED_TOP_LEVEL - data.keys()
    if missing:
        raise ValueError(f"missing keys: {', '.join(sorted(missing))}")
    actions = data["actions"]
    if not isinstance(actions, dict) or not actions:
        raise ValueError("actions must be a non-empty mapping")
    if data["start"] not in actions:
        raise ValueError("start action not defined in actions")
    for name, action in actions.items():
        if REQUIRED_ACTION_KEYS - action.keys():
            raise ValueError(f"action '{name}' missing keys")


def main() -> int:
    base = pathlib.Path(__file__).resolve().parent.parent / "playbooks"
    ok = True
    for file in base.glob("*.yml"):
        try:
            validate_playbook(file)
            print(f"{file.name}: OK")
        except Exception as exc:
            ok = False
            print(f"{file.name}: {exc}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
