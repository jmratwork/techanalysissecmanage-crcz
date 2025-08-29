#!/bin/bash
set -euo pipefail

CTI_FEED_URL="${CTI_FEED_URL:-https://misp.internal.example.com/taxii2/collections/indicators/objects}"
CTI_FETCH_INTERVAL="${CTI_FETCH_INTERVAL:-300}"
OUTPUT_DIR="${CTI_FEED_OUTPUT_DIR:-/var/log/misp}"
export OUTPUT_DIR

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v curl >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y curl
    fi
}

fetch_loop() {
    mkdir -p "${OUTPUT_DIR}"
    while true; do
        if curl -fsSL "$CTI_FEED_URL" -o "${OUTPUT_DIR}/cti_feed.stix"; then
            python3 <<'PYEOF' >>"${OUTPUT_DIR}/ingest.log" 2>&1
import json
import sys
import requests
from stix2 import parse
import os

out_dir = os.environ.get("OUTPUT_DIR", ".")
stix_path = os.path.join(out_dir, "cti_feed.stix")
out_path = os.path.join(out_dir, "cti_enriched.json")

with open(stix_path) as f:
    bundle = parse(f.read())

enriched = []
for obj in getattr(bundle, "objects", []):
    attack_id = next((ref.get("external_id") for ref in obj.get("external_references", []) if ref.get("source_name") == "mitre-attack" and ref.get("external_id")), None)
    if attack_id:
        print(f"Mapped {obj.get('id')} to ATT&CK {attack_id}")
        obj["mitre_attack_id"] = attack_id

    cve_ids = [ref.get("external_id") for ref in obj.get("external_references", []) if ref.get("source_name") == "cve" and ref.get("external_id")]
    if cve_ids:
        cpes = []
        for cve in cve_ids:
            try:
                r = requests.get(f"https://cve.circl.lu/api/cve/{cve}", timeout=5)
                if r.status_code == 200:
                    data = r.json()
                    cpe_entries = data.get("cpe") or []
                    if cpe_entries:
                        cpes.extend(cpe_entries)
                        print(f"Mapped {cve} to CPE {cpe_entries}")
            except Exception as exc:
                print(f"Failed to map {cve}: {exc}")
        if cpes:
            obj["cpe"] = cpes

    enriched.append(obj)

with open(out_path, "w") as fh:
    json.dump([o for o in enriched], fh)
PYEOF

            if command -v misp-cli >/dev/null 2>&1; then
                misp-cli ingest "${OUTPUT_DIR}/cti_enriched.json" >>"${OUTPUT_DIR}/ingest.log" 2>&1 || true
            fi
        fi
        sleep "$CTI_FETCH_INTERVAL"
    done
}

install_deps
fetch_loop
