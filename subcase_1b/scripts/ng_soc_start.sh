#!/bin/bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-/var/log/ng_soc/start.log}"

start_soc() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$(date) NG-SOC monitoring activated" >> "$LOG_FILE"
}

start_soc
