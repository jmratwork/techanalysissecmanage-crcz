import json
from flask import Flask, request, jsonify
import requests

DECIDE_URL = "http://localhost:8000/recommend"

app = Flask(__name__)


def block_ip(ip: str) -> None:
    """Simulate blocking an IP address."""
    print(f"[ACT] Blocking IP: {ip}")


def isolate_host(host: str) -> None:
    """Simulate isolating a host from the network."""
    print(f"[ACT] Isolating host: {host}")


def monitor(target: str) -> None:
    """Default fallback action."""
    print(f"[ACT] Monitoring target: {target}")


ACTIONS = {
    "block_ip": block_ip,
    "isolate_host": isolate_host,
    "monitor": monitor,
}


@app.post("/act")
def act() -> "Response":
    """Receive event data, query Decide, and apply recommended mitigation."""
    payload = request.get_json(force=True)
    target = payload.get("target", "")

    # Query Decide for recommended mitigation
    response = requests.post(DECIDE_URL, json=payload, timeout=5)
    mitigation = response.json().get("mitigation", "monitor")

    # Execute the corresponding action
    action = ACTIONS.get(mitigation, monitor)
    action(target)

    return jsonify({"mitigation": mitigation, "target": target})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8100)
