#!/usr/bin/env python3
"""Simple IDS alert processor with ML classification and MISP enrichment.

This module parses Suricata EVE JSON alerts, applies a scikit-learn model to
classify each event as benign or malicious, and updates Suricata rules using a
MISP threat intelligence feed.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Iterable, List

import joblib
import requests
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB

sys.path.append(str(Path(__file__).resolve().parents[2]))
from soc_alerts.notifier import Notifier
from soc_alerts.service import AlertService

MODEL_FILE = Path(__file__).with_name("model.joblib")
DEFAULT_ALERT_FILE = Path("/var/log/suricata/eve.json")
DEFAULT_RULE_FILE = Path("/etc/suricata/rules/misp.rules")
DEFAULT_LOG_FILE = Path("/var/log/bips/alerts.json")


def train_model() -> None:
    """Train a trivial text classifier and persist it."""
    samples = [
        "Exploit attempt detected",
        "Known malicious IP",
        "Normal HTTP traffic",
        "Benign DNS query",
    ]
    labels = [1, 1, 0, 0]  # 1 = malicious, 0 = benign
    vectorizer = CountVectorizer()
    features = vectorizer.fit_transform(samples)
    model = MultinomialNB().fit(features, labels)
    joblib.dump((vectorizer, model), MODEL_FILE)


def load_model():
    """Load the classifier, training it first if necessary."""
    if not MODEL_FILE.exists():
        train_model()
    return joblib.load(MODEL_FILE)


def classify_event(event: dict) -> int:
    """Classify a single Suricata alert event."""
    vectorizer, model = load_model()
    text = event.get("alert", {}).get("signature", "")
    features = vectorizer.transform([text])
    return int(model.predict(features)[0])


def process_alerts(path: Path) -> List[dict]:
    """Process alerts from the given EVE JSON file."""
    results = []
    if not path.exists():
        return results
    with path.open() as handle:
        for line in handle:
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            label = classify_event(event)
            results.append({"event": event, "label": label})
    return results


def write_alerts(alerts: List[dict], log_file: Path = DEFAULT_LOG_FILE) -> None:
    """Write classification results as JSON lines for SIEM ingestion."""
    if not alerts:
        return
    log_file.parent.mkdir(parents=True, exist_ok=True)
    with log_file.open("a") as handle:
        for alert in alerts:
            event = alert.get("event", {})
            record = {
                "timestamp": event.get("timestamp"),
                "signature": event.get("alert", {}).get("signature"),
                "src_ip": event.get("src_ip"),
                "dest_ip": event.get("dest_ip"),
                "label": alert.get("label"),
            }
            handle.write(json.dumps(record) + "\n")


def fetch_misp_iocs(url: str) -> Iterable[str]:
    """Fetch indicators from a MISP JSON feed endpoint."""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()
    except Exception:
        return []
    return data.get("iocs", [])


def update_rules_from_misp(url: str, rules_file: Path) -> None:
    """Append MISP IOCs to a Suricata rules file."""
    iocs = fetch_misp_iocs(url)
    if not iocs:
        return
    rules_file.parent.mkdir(parents=True, exist_ok=True)
    with rules_file.open("a") as handle:
        for idx, ioc in enumerate(iocs, start=1):
            rule = (
                f"alert ip {ioc} any -> any any "
                f"(msg:\"MISP IOC {ioc}\"; sid:100000{idx}; rev:1;)\n"
            )
            handle.write(rule)


def main() -> None:
    parser = argparse.ArgumentParser(description="Process IDS alerts with ML")
    parser.add_argument("--alert-file", type=Path, default=DEFAULT_ALERT_FILE)
    parser.add_argument("--misp-url", default="http://localhost:8443/feed.json")
    parser.add_argument(
        "--update-rules",
        action="store_true",
        help="Fetch MISP feed and append indicators to Suricata rules",
    )
    parser.add_argument(
        "--notify-method",
        choices=["email", "syslog"],
        default="syslog",
        help="Notification channel for SOC alerts",
    )
    parser.add_argument(
        "--email-to",
        help="Destination email when using email notification",
    )
    args = parser.parse_args()

    if args.update_rules:
        update_rules_from_misp(args.misp_url, DEFAULT_RULE_FILE)

    notify_config = {"method": args.notify_method}
    if args.notify_method == "email":
        if not args.email_to:
            parser.error("--email-to required with --notify-method=email")
        notify_config["to"] = args.email_to
    notifier = Notifier(notify_config)
    alert_service = AlertService(notifier)

    results = process_alerts(args.alert_file)
    write_alerts(results)
    for res in results:
        if res.get("label") == 1:
            event = res.get("event", {})
            signature = event.get("alert", {}).get("signature", "malicious")
            host = event.get("dest_ip") or event.get("src_ip") or "unknown"
            alert_service.handle_event("ids_ml", signature, host)
        print(json.dumps(res))


if __name__ == "__main__":
    main()
