from pathlib import Path

from flask import Flask, request, jsonify
import requests

from soar_engine import SoarEngine

DECIDE_URL = "http://localhost:8000/recommend"
PLAYBOOK_DIR = Path(__file__).resolve().parent.parent / "playbooks"

app = Flask(__name__)
engine = SoarEngine(PLAYBOOK_DIR)


def monitor(target: str) -> None:
    """Default fallback action."""
    print(f"[ACT] Monitoring target: {target}")


ACTIONS = {
    "isolate_host": {"func": engine.isolate_host, "playbook": "isolation"},
    "eradicate_malware": {"func": engine.eradicate_malware, "playbook": "eradication"},
    "recover_host": {"func": lambda host: engine.execute("recovery", host=host), "playbook": "recovery"},
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
    action = info["func"]
    action(target)

    return jsonify({
        "mitigation": mitigation,
        "target": target,
        "playbook": info.get("playbook"),
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8100)
