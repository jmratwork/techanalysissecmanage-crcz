import os
import time
import uuid
from typing import Any

import requests
import jwt


class OpenEdXClient:
    """Client for Open edX LMS and KYPO LTI integrations."""

    def __init__(self, base_url: str | None = None):
        # Open edX configuration
        self.base_url = (
            base_url or os.environ.get("OPENEDX_URL", "http://localhost:8000")
        ).rstrip("/")

        # LTI / KYPO configuration. Defaults are suitable for local
        # development and can be overridden via environment variables.
        self.kypo_url = os.environ.get("KYPO_URL", "http://localhost:5000").rstrip("/")
        self.lti_client_id = os.environ.get("LTI_CLIENT_ID", "kypo-consumer")
        self.lti_deployment_id = os.environ.get(
            "LTI_DEPLOYMENT_ID", "kypo-deployment"
        )
        self.lti_launch_url = os.environ.get(
            "KYPO_LTI_LAUNCH_URL", f"{self.kypo_url}/lti/launch"
        )
        # Private key used to sign LTI launch tokens. The variable can
        # contain either the key itself or a path to a file.
        key = os.environ.get("LTI_TOOL_PRIVATE_KEY", "")
        if os.path.exists(key):
            with open(key, "r", encoding="utf-8") as fh:
                key = fh.read()
        self.lti_private_key = key or None

    # ------------------------------------------------------------------
    # Open edX progress reporting
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

    # ------------------------------------------------------------------
    # KYPO LTI consumer
    def generate_launch_url(self, username: str, lab_id: str) -> str:
        """Create an LTI 1.3 launch URL for the given user and KYPO lab.

        The token is signed locally and appended to the KYPO launch URL.
        Only a subset of the LTI specification is implemented which is
        sufficient for triggering KYPO lab sessions.
        """

        if not self.lti_private_key:
            raise ValueError("LTI_TOOL_PRIVATE_KEY not configured")

        now = int(time.time())
        payload = {
            "iss": self.lti_client_id,
            "aud": self.kypo_url,
            "iat": now,
            "exp": now + 300,  # five minutes
            "nonce": str(uuid.uuid4()),
            "sub": username,
            "https://purl.imsglobal.org/spec/lti/claim/message_type": "LtiResourceLinkRequest",
            "https://purl.imsglobal.org/spec/lti/claim/version": "1.3.0",
            "https://purl.imsglobal.org/spec/lti/claim/deployment_id": self.lti_deployment_id,
            "https://purl.imsglobal.org/spec/lti/claim/resource_link": {"id": lab_id},
            "https://purl.imsglobal.org/spec/lti/claim/target_link_uri": f"{self.kypo_url}/labs/{lab_id}",
        }

        id_token = jwt.encode(payload, self.lti_private_key, algorithm="RS256")
        state = str(uuid.uuid4())
        return f"{self.lti_launch_url}?id_token={id_token}&state={state}"
