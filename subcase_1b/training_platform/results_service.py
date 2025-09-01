from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

RESULTS_FILE = Path(__file__).with_name("results.json")


def _load() -> List[Dict[str, Any]]:
    if RESULTS_FILE.exists():
        try:
            return json.loads(RESULTS_FILE.read_text())
        except json.JSONDecodeError:
            return []
    return []


def append_result(result: Dict[str, Any]) -> None:
    """Append a result entry to the results file."""
    data = _load()
    data.append(result)
    RESULTS_FILE.write_text(json.dumps(data, indent=2))
