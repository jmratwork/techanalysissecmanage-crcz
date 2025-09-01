import os
from typing import Any

import requests


class OpenEdXClient:
    """Simple client to send progress updates to an Open edX instance."""

    def __init__(self, base_url: str | None = None):
        self.base_url = (base_url or os.environ.get("OPENEDX_URL", "http://localhost:8000")).rstrip("/")

    def update_progress(self, username: str, course_id: str, progress: Any) -> None:
        """POST progress information to the Open edX courseware API.

        Network errors are ignored so training can proceed even if the
        Open edX instance is unavailable.
        """
        payload = {"username": username, "course_id": course_id, "progress": progress}
        url = f"{self.base_url}/courseware/progress"
        try:
            requests.post(url, json=payload, timeout=5)
        except requests.RequestException:
            # The integration is best-effort; failures are silently ignored.
            pass
