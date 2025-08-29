#!/bin/bash
set -euo pipefail

TARGET="${TARGET:-10.10.0.4}"
SCAN_LOG="${SCAN_LOG:-/var/log/trainee/scans.log}"

APT_UPDATED=0
apt_update_once() {
    if [ "$APT_UPDATED" -eq 0 ]; then
        export DEBIAN_FRONTEND=noninteractive
        if ! apt-get update -y; then
            echo "$(date) apt-get update failed" >&2
            return 1
        fi
        APT_UPDATED=1
    fi
}

install_deps() {
    if ! command -v rustscan >/dev/null 2>&1; then
        apt_update_once || return 1
        export DEBIAN_FRONTEND=noninteractive
        if ! apt-get install -y rustscan; then
            echo "$(date) failed to install rustscan" >&2
            return 1
        fi
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
