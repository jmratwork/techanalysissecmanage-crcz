#!/bin/bash
set -euo pipefail

BIPS_PORT="${BIPS_PORT:-5500}"
NG_SIEM_PORT="${NG_SIEM_PORT:-5601}"
CICMS_PORT="${CICMS_PORT:-5800}"
NG_SOC_PORT="${NG_SOC_PORT:-5900}"

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

start_bips() {
    mkdir -p /var/log/bips
    if systemctl is-active --quiet bips; then
        return 0
    fi
    if systemctl start bips >>/var/log/bips/service.log 2>&1; then
        if ! systemctl is-active --quiet bips; then
            echo "$(date) bips failed to start" >>/var/log/bips/service.log
            return 1
        fi
        check_port localhost "${BIPS_PORT}" >>/var/log/bips/service.log 2>&1 || {
            echo "$(date) bips port check failed" >>/var/log/bips/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start bips" >>/var/log/bips/service.log
        return 1
    fi
}

start_ng_siem() {
    mkdir -p /var/log/ng_siem
    if systemctl is-active --quiet ng-siem; then
        return 0
    fi
    if systemctl start ng-siem >>/var/log/ng_siem/service.log 2>&1; then
        if ! systemctl is-active --quiet ng-siem; then
            echo "$(date) ng-siem failed to start" >>/var/log/ng_siem/service.log
            return 1
        fi
        check_port localhost "${NG_SIEM_PORT}" >>/var/log/ng_siem/service.log 2>&1 || {
            echo "$(date) ng-siem port check failed" >>/var/log/ng_siem/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start ng-siem" >>/var/log/ng_siem/service.log
        return 1
    fi
}

start_cicms() {
    mkdir -p /var/log/cicms
    if systemctl is-active --quiet cicms; then
        return 0
    fi
    if systemctl start cicms >>/var/log/cicms/service.log 2>&1; then
        if ! systemctl is-active --quiet cicms; then
            echo "$(date) cicms failed to start" >>/var/log/cicms/service.log
            return 1
        fi
        check_port localhost "${CICMS_PORT}" >>/var/log/cicms/service.log 2>&1 || {
            echo "$(date) cicms port check failed" >>/var/log/cicms/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start cicms" >>/var/log/cicms/service.log
        return 1
    fi
}

start_ng_soc() {
    mkdir -p /var/log/ng_soc
    if systemctl is-active --quiet ng-soc; then
        return 0
    fi
    if systemctl start ng-soc >>/var/log/ng_soc/service.log 2>&1; then
        if ! systemctl is-active --quiet ng-soc; then
            echo "$(date) ng-soc failed to start" >>/var/log/ng_soc/service.log
            return 1
        fi
        check_port localhost "${NG_SOC_PORT}" >>/var/log/ng_soc/service.log 2>&1 || {
            echo "$(date) ng-soc port check failed" >>/var/log/ng_soc/service.log
            return 1
        }
    else
        echo "$(date) failed to run systemctl start ng-soc" >>/var/log/ng_soc/service.log
        return 1
    fi
}

install_deps
start_bips
start_ng_siem
start_cicms
start_ng_soc
