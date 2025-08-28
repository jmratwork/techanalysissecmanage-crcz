#!/bin/bash
set -euo pipefail

C2_BIND_IP="${C2_BIND_IP:-0.0.0.0}"
C2_PORT="${C2_PORT:-9001}"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y python3
    fi

    if ! command -v nc >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y netcat
    fi
}

setup_c2() {
    mkdir -p /opt/c2_server
    cp "$(dirname "$0")/c2_server.py" /opt/c2_server/c2_server.py

    cat >/etc/systemd/system/c2_server.service <<EOF
[Unit]
Description=Simple C2 Server
After=network.target

[Service]
Type=simple
Environment="C2_BIND_IP=${C2_BIND_IP}" "C2_PORT=${C2_PORT}"
ExecStart=/usr/bin/python3 /opt/c2_server/c2_server.py
Restart=on-failure
StandardOutput=append:/var/log/c2_server/c2_server.log
StandardError=append:/var/log/c2_server/c2_server.log
ExecStartPre=/bin/mkdir -p /var/log/c2_server

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable c2_server.service >/dev/null 2>&1 || true
}

start_c2() {
    mkdir -p /var/log/c2_server
    if systemctl start c2_server.service >>/var/log/c2_server/service.log 2>&1; then
        if ! systemctl is-active --quiet c2_server.service; then
            echo "$(date) c2_server failed to start" >>/var/log/c2_server/service.log
            return 1
        fi
        nc -z localhost "${C2_PORT}" >>/var/log/c2_server/service.log 2>&1 || {
            echo "$(date) c2_server port check failed" >>/var/log/c2_server/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start c2_server" >>/var/log/c2_server/service.log
        return 1
    fi
}

install_deps
setup_c2
start_c2
