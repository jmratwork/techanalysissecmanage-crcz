#!/bin/bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-/var/log/bips/start.log}"
IDS_ML_DIR="$(cd "$(dirname "$0")/.." && pwd)/bips"
ML_SCRIPT="$IDS_ML_DIR/ids_ml.py"

start_bips() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$(date) Starting Suricata service" >> "$LOG_FILE"
    if command -v systemctl >/dev/null 2>&1; then
        systemctl start suricata || true
    fi
    echo "$(date) Launching BIPS ML processor" >> "$LOG_FILE"
    python3 "$ML_SCRIPT" --update-rules &>> "$LOG_FILE" &
}

start_bips
