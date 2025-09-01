import pathlib
from typing import Dict, Any, Optional

import yaml
from jinja2 import Template


class SoarEngine:
    """Simple SOAR engine that loads and executes YAML playbooks."""

    def __init__(self, playbook_dir: pathlib.Path) -> None:
        self.playbook_dir = playbook_dir
        self.playbooks: Dict[str, Dict[str, Any]] = {}
        self._load_playbooks()

    def _load_playbooks(self) -> None:
        for path in self.playbook_dir.glob("*.yml"):
            with path.open() as fh:
                data = yaml.safe_load(fh)
            # store playbook using file stem as key
            self.playbooks[path.stem] = data

    def execute(self, name: str, **params: Any) -> None:
        """Run the playbook ``name`` with ``params``."""
        playbook = self.playbooks.get(name)
        if not playbook:
            print(f"[SOAR] Playbook '{name}' not found")
            return
        actions = playbook.get("actions", {})
        current: Optional[str] = playbook.get("start")
        while current:
            action = actions.get(current)
            if action is None:
                print(f"[SOAR] Unknown action '{current}' in playbook '{name}'")
                break
            description = action.get("description", "")
            command_tpl = Template(action.get("command", ""))
            command = command_tpl.render(**params)
            print(f"[SOAR] {description}")
            print(f"[SOAR] Executing: {command}")
            current = action.get("next")

    # Convenience wrappers for common actions
    def isolate_host(self, host: str) -> None:
        self.execute("isolation", host=host)

    def eradicate_malware(self, host: str) -> None:
        self.execute("eradication", host=host)


__all__ = ["SoarEngine"]
