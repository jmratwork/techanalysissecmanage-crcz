#!/bin/bash
set -euo pipefail

# IP address of the target host; override with TARGET_IP env var
TARGET_IP="${TARGET_IP:-127.0.0.1}"

install_deps() {
    # Skip installation during testing by setting SKIP_INSTALL=1
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v nmap >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y nmap
    fi
}

configure_attacker() {
    mkdir -p /var/log/attacker
}

start_attacker_tools() {
    # Example action: run a background scan against the target
    if command -v nmap >/dev/null 2>&1; then
        nmap -Pn "$TARGET_IP" > /var/log/attacker/scan.log 2>&1 &
    else
        ping -c1 "$TARGET_IP" > /var/log/attacker/scan.log 2>&1 &
    fi
}

install_deps
configure_attacker
start_attacker_tools
