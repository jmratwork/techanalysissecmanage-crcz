#!/bin/bash
set -euo pipefail

CTI_FEED_URL="${CTI_FEED_URL:-https://example.com/feed.json}"
CTI_FETCH_INTERVAL="${CTI_FETCH_INTERVAL:-300}"
OUTPUT_DIR="${CTI_FEED_OUTPUT_DIR:-/var/log/ctems}"

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
        curl -fsSL "$CTI_FEED_URL" -o "${OUTPUT_DIR}/cti_feed.log" || true
        sleep "$CTI_FETCH_INTERVAL"
    done
}

install_deps
fetch_loop
