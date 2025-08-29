#!/bin/bash
set -euo pipefail

RANGE_LOG="${RANGE_LOG:-/var/log/cyber_range/launch.log}"
VULN_PROFILE="${VULN_PROFILE:-baseline}"

initialize_range() {
    mkdir -p "$(dirname "$RANGE_LOG")"
    echo "$(date) Cyber Range initialized with profile $VULN_PROFILE" >> "$RANGE_LOG"
}

initialize_range
