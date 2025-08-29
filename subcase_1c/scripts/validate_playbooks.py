#!/usr/bin/env python3
"""Basic validation for YAML playbooks."""
import sys
import pathlib
import yaml

REQUIRED_TOP_LEVEL = {"name", "description", "steps"}
REQUIRED_STEP_KEYS = {"description", "command"}


def validate_playbook(path: pathlib.Path) -> None:
    with path.open() as f:
        data = yaml.safe_load(f)
    missing = REQUIRED_TOP_LEVEL - data.keys()
    if missing:
        raise ValueError(f"missing keys: {', '.join(sorted(missing))}")
    if not isinstance(data["steps"], list) or not data["steps"]:
        raise ValueError("steps must be a non-empty list")
    for idx, step in enumerate(data["steps"], start=1):
        if REQUIRED_STEP_KEYS - step.keys():
            raise ValueError(f"step {idx} missing keys")


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
