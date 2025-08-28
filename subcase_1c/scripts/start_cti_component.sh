#!/bin/bash
set -euo pipefail

CTI_FEED_URL="${CTI_FEED_URL:-https://example.com/feed.json}"
CTI_FETCH_INTERVAL="${CTI_FETCH_INTERVAL:-300}"
CTEMS_PORT="${CTEMS_PORT:-5700}"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v curl >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y curl
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y python3
    fi
}

start_cti() {
    while true; do
        curl -fsSL "$CTI_FEED_URL" -o /var/log/cti_feed.json || true
        sleep "$CTI_FETCH_INTERVAL"
    done &
}

start_component() {
    local name="$1"
    local port="$2"
    mkdir -p "/var/log/${name}"
    python3 -m http.server "$port" --bind 0.0.0.0 >"/var/log/${name}/service.log" 2>&1 &
}

install_deps
start_cti
start_component ctems "$CTEMS_PORT"
