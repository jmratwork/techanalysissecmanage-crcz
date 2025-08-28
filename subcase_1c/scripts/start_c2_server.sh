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
}

start_c2() {
    cat <<EOF >/tmp/c2_server.py
import socket, threading
bind_ip = "${C2_BIND_IP}"
port = int("${C2_PORT}")
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((bind_ip, port))
server.listen(5)
def handle(client):
    client.send(b"Connected to C2\\n")
    client.close()
while True:
    client, addr = server.accept()
    threading.Thread(target=handle, args=(client,), daemon=True).start()
EOF
    python3 /tmp/c2_server.py >/var/log/c2.log 2>&1 &
}

install_deps
start_c2
