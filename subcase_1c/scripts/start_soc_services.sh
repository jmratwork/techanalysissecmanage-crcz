#!/bin/bash
set -euo pipefail

BIPS_PORT="${BIPS_PORT:-5500}"
NG_SIEM_PORT="${NG_SIEM_PORT:-5601}"
CICMS_PORT="${CICMS_PORT:-5800}"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y python3
    fi
}

start_component() {
    local name="$1"
    local port="$2"
    mkdir -p "/var/log/${name}"
    python3 -m http.server "$port" --bind 0.0.0.0 >"/var/log/${name}/service.log" 2>&1 &
}

install_deps
start_component bips "$BIPS_PORT"
start_component ng_siem "$NG_SIEM_PORT"
start_component cicms "$CICMS_PORT"
