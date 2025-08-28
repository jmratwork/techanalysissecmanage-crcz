#!/bin/bash
set -euo pipefail

CTI_FEED_URL="${CTI_FEED_URL:-https://example.com/feed.json}"
CTI_FETCH_INTERVAL="${CTI_FETCH_INTERVAL:-300}"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v curl >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y curl
    fi
}

start_cti() {
    while true; do
        curl -fsSL "$CTI_FEED_URL" -o /var/log/cti_feed.json || true
        sleep "$CTI_FETCH_INTERVAL"
    done &
}

install_deps
start_cti
