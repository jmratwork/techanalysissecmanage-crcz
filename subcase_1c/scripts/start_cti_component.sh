#!/bin/bash
set -euo pipefail

CTEMS_PORT="${CTEMS_PORT:-5700}"
NG_SIEM_PORT="${NG_SIEM_PORT:-5601}"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v nc >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y netcat
    fi
}

start_ctems() {
    mkdir -p /var/log/ctems
    if systemctl start ctems >>/var/log/ctems/service.log 2>&1; then
        if ! systemctl is-active --quiet ctems; then
            echo "$(date) ctems failed to start" >>/var/log/ctems/service.log
            return 1
        fi
        nc -z localhost "${CTEMS_PORT}" >>/var/log/ctems/service.log 2>&1 || {
            echo "$(date) ctems port check failed" >>/var/log/ctems/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start ctems" >>/var/log/ctems/service.log
        return 1
    fi
}

start_ng_siem() {
    mkdir -p /var/log/ng_siem
    if systemctl start ng-siem >>/var/log/ng_siem/service.log 2>&1; then
        if ! systemctl is-active --quiet ng-siem; then
            echo "$(date) ng-siem failed to start" >>/var/log/ng_siem/service.log
            return 1
        fi
        nc -z localhost "${NG_SIEM_PORT}" >>/var/log/ng_siem/service.log 2>&1 || {
            echo "$(date) ng-siem port check failed" >>/var/log/ng_siem/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start ng-siem" >>/var/log/ng_siem/service.log
        return 1
    fi
}

install_deps
start_ctems
start_ng_siem
"$(dirname "$0")/fetch_cti_feed.sh" &
