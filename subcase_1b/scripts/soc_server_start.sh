#!/bin/bash
set -euo pipefail

# Network address and port to bind the SOC service
SOC_SERVER_IP="${SOC_SERVER_IP:-0.0.0.0}"
SOC_SERVER_PORT="${SOC_SERVER_PORT:-0}"
# Default administrative credentials
SOC_ADMIN_USER="${SOC_ADMIN_USER:-admin}"
SOC_ADMIN_PASS="${SOC_ADMIN_PASS:-password}"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y python3
    fi
}

configure_service() {
    mkdir -p /opt/ngsoc
    cat <<EOF >/opt/ngsoc/credentials.env
SOC_ADMIN_USER=${SOC_ADMIN_USER}
SOC_ADMIN_PASS=${SOC_ADMIN_PASS}
EOF
}

start_service() {
    python3 -m http.server "$SOC_SERVER_PORT" --bind "$SOC_SERVER_IP" >/var/log/soc.log 2>&1 &
}

install_deps
configure_service
start_service
