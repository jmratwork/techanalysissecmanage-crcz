#!/bin/bash
set -euo pipefail

TARGET="${TARGET:-10.10.0.4}"
SCAN_LOG="${SCAN_LOG:-/var/log/trainee/scans.log}"

install_deps() {
    if ! command -v rustscan >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y rustscan
    fi
}

run_scan() {
    mkdir -p "$(dirname "$SCAN_LOG")"
    if rustscan -a "$TARGET" >> "$SCAN_LOG" 2>&1; then
        echo "$(date) Completed scan against $TARGET" >> "$SCAN_LOG"
    else
        echo "$(date) Scan failed for $TARGET" >> "$SCAN_LOG"
    fi
}

install_deps
run_scan
