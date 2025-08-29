#!/bin/bash
set -euo pipefail

MISP_PORT="${MISP_PORT:-8443}"

if [ -f /etc/misp/cti_feed.env ]; then
    # shellcheck disable=SC1091
    . /etc/misp/cti_feed.env
    export CTI_FEED_URL
fi

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v timeout >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y coreutils
    fi
}

check_port() {
    timeout 5 bash -c "cat < /dev/null > /dev/tcp/$1/$2"
}

start_misp() {
    mkdir -p /var/log/misp
    if systemctl is-active --quiet misp; then
        return 0
    fi
    if systemctl start misp >>/var/log/misp/service.log 2>&1; then
        if ! systemctl is-active --quiet misp; then
            echo "$(date) misp failed to start" >>/var/log/misp/service.log
            return 1
        fi
        check_port localhost "${MISP_PORT}" >>/var/log/misp/service.log 2>&1 || {
            echo "$(date) misp port check failed" >>/var/log/misp/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start misp" >>/var/log/misp/service.log
        return 1
    fi
}

start_fetch_cti_feed() {
    mkdir -p /var/log/misp
    if systemctl is-active --quiet fetch-cti-feed; then
        return 0
    fi
    if systemctl start fetch-cti-feed >>/var/log/misp/service.log 2>&1; then
        if ! systemctl is-active --quiet fetch-cti-feed; then
            echo "$(date) fetch-cti-feed failed to start" >>/var/log/misp/service.log
            return 1
        fi
    else
        echo "$(date) failed to run systemctl start fetch-cti-feed" >>/var/log/misp/service.log
        return 1
    fi
}

install_deps
start_misp
start_fetch_cti_feed
