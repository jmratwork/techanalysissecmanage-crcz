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


def eradicate_malware(host: str) -> None:
    """Simulate malware eradication."""
    print(f"[ACT] Eradicating malware on: {host}")


def recover_host(host: str) -> None:
    """Simulate restoring services after eradication."""
    print(f"[ACT] Recovering host: {host}")


def monitor(target: str) -> None:
    """Default fallback action."""
    print(f"[ACT] Monitoring target: {target}")


ACTIONS = {
    "block_ip": {"func": block_ip, "playbook": "../playbooks/isolation.yml"},
    "isolate_host": {"func": isolate_host, "playbook": "../playbooks/isolation.yml"},
    "eradicate_malware": {"func": eradicate_malware, "playbook": "../playbooks/eradication.yml"},
    "recover_host": {"func": recover_host, "playbook": "../playbooks/recovery.yml"},
    "monitor": {"func": monitor, "playbook": None},
}


@app.post("/act")
def act() -> "Response":
    """Receive event data, query Decide, and apply recommended mitigation."""
    payload = request.get_json(force=True)
    target = payload.get("target", "")
    mitigation = payload.get("mitigation")

    if mitigation is None:
        # Query Decide for recommended mitigation
        response = requests.post(DECIDE_URL, json=payload, timeout=5)
        mitigation = response.json().get("mitigation", "monitor")

    info = ACTIONS.get(mitigation, ACTIONS["monitor"])

    if info.get("playbook"):
        print(f"[ACT] Refer to {info['playbook']} for manual steps")

    # Execute the corresponding action
    action = info["func"]
    action(target)

    return jsonify({"mitigation": mitigation, "target": target, "playbook": info.get("playbook")})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8100)
