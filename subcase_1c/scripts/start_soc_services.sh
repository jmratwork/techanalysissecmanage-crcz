#!/bin/bash
set -euo pipefail

USE_SYSTEMCTL=1
if ! command -v systemctl >/dev/null 2>&1; then
    if [ "${DIRECT_START:-0}" -eq 1 ]; then
        USE_SYSTEMCTL=0
        echo "systemctl not found; using direct start mode" >&2
    else
        echo "systemctl command not found. Set DIRECT_START=1 to run without systemd." >&2
        exit 1
    fi
fi

BIPS_PORT="${BIPS_PORT:-5500}"
NG_SIEM_PORT="${NG_SIEM_PORT:-5601}"
CICMS_PORT="${CICMS_PORT:-5800}"
NG_SOC_PORT="${NG_SOC_PORT:-5900}"
DECIDE_PORT="${DECIDE_PORT:-8000}"
ACT_PORT="${ACT_PORT:-8100}"
SIEM_UI_PORT="${SIEM_UI_PORT:-5602}"

APT_UPDATED=0
apt_update_once() {
    if [ "$APT_UPDATED" -eq 0 ]; then
        export DEBIAN_FRONTEND=noninteractive
        if ! apt-get update -y; then
            echo "$(date) apt-get update failed" >&2
            return 1
        fi
        APT_UPDATED=1
    fi
}

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v timeout >/dev/null 2>&1; then
        apt_update_once || return 1
        export DEBIAN_FRONTEND=noninteractive
        if ! apt-get install -y coreutils; then
            echo "$(date) failed to install coreutils" >&2
            return 1
        fi
    fi
}

check_port() {
    timeout 5 bash -c "cat < /dev/null > /dev/tcp/$1/$2"
}

start_bips() {
    mkdir -p /var/log/bips
    if [ "$USE_SYSTEMCTL" -eq 1 ]; then
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
    else
        if command -v service >/dev/null 2>&1; then
            if service bips start >>/var/log/bips/service.log 2>&1; then
                check_port localhost "${BIPS_PORT}" >>/var/log/bips/service.log 2>&1 || {
                    echo "$(date) bips port check failed" >>/var/log/bips/service.log
                    return 1
                }
            else
                echo "$(date) failed to run service bips start" >>/var/log/bips/service.log
                return 1
            fi
        else
            echo "$(date) service command not found" >>/var/log/bips/service.log
            return 1
        fi
    fi
}

start_ng_siem() {
    mkdir -p /var/log/ng_siem
    local compose_cmd
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        compose_cmd="docker compose"
    elif command -v docker-compose >/dev/null 2>&1; then
        compose_cmd="docker-compose"
    else
        echo "$(date) docker compose command not found" >>/var/log/ng_siem/service.log
        return 1
    fi

    if $compose_cmd -f /etc/ng_siem/docker-compose.yml up -d >>/var/log/ng_siem/service.log 2>&1; then
        check_port localhost "${NG_SIEM_PORT}" >>/var/log/ng_siem/service.log 2>&1 || {
            echo "$(date) ng-siem port check failed" >>/var/log/ng_siem/service.log
            return 1
        }
    else
        echo "$(date) failed to run $compose_cmd up" >>/var/log/ng_siem/service.log
        return 1
    fi
}

start_siem_ui() {
    mkdir -p /var/log/siem_ui
    if ! command -v docker >/dev/null 2>&1; then
        echo "$(date) docker command not found" >>/var/log/siem_ui/service.log
        return 1
    fi

    if ! docker ps --format '{{.Names}}' | grep -q '^kibana$'; then
        if docker ps -a --format '{{.Names}}' | grep -q '^kibana$'; then
            docker start kibana >>/var/log/siem_ui/service.log 2>&1 || {
                echo "$(date) failed to start existing kibana container" >>/var/log/siem_ui/service.log
                return 1
            }
        else
            docker run -d --name kibana -p "${SIEM_UI_PORT}:5601" kibana:7.17.0 >>/var/log/siem_ui/service.log 2>&1 || {
                echo "$(date) failed to run kibana container" >>/var/log/siem_ui/service.log
                return 1
            }
        fi
    fi

    check_port localhost "${SIEM_UI_PORT}" >>/var/log/siem_ui/service.log 2>&1 || {
        echo "$(date) siem-ui port check failed" >>/var/log/siem_ui/service.log
        return 1
    }
}

start_cicms() {
    mkdir -p /var/log/cicms
    if [ "$USE_SYSTEMCTL" -eq 1 ]; then
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
    else
        if command -v service >/dev/null 2>&1; then
            if service cicms start >>/var/log/cicms/service.log 2>&1; then
                check_port localhost "${CICMS_PORT}" >>/var/log/cicms/service.log 2>&1 || {
                    echo "$(date) cicms port check failed" >>/var/log/cicms/service.log
                    return 1
                }
            else
                echo "$(date) failed to run service cicms start" >>/var/log/cicms/service.log
                return 1
            fi
        else
            echo "$(date) service command not found" >>/var/log/cicms/service.log
            return 1
        fi
    fi
}

start_ng_soc() {
    mkdir -p /var/log/ng_soc
    if [ "$USE_SYSTEMCTL" -eq 1 ]; then
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
    else
        if command -v service >/dev/null 2>&1; then
            if service ng-soc start >>/var/log/ng_soc/service.log 2>&1; then
                check_port localhost "${NG_SOC_PORT}" >>/var/log/ng_soc/service.log 2>&1 || {
                    echo "$(date) ng-soc port check failed" >>/var/log/ng_soc/service.log
                    return 1
                }
            else
                echo "$(date) failed to run service ng-soc start" >>/var/log/ng_soc/service.log
                return 1
            fi
        else
            echo "$(date) service command not found" >>/var/log/ng_soc/service.log
            return 1
        fi
    fi
}

start_decide() {
    mkdir -p /var/log/decide
    if [ "$USE_SYSTEMCTL" -eq 1 ]; then
        if systemctl is-active --quiet decide; then
            return 0
        fi
        if systemctl start decide >>/var/log/decide/service.log 2>&1; then
            if ! systemctl is-active --quiet decide; then
                echo "$(date) decide failed to start" >>/var/log/decide/service.log
                return 1
            fi
            check_port localhost "${DECIDE_PORT}" >>/var/log/decide/service.log 2>&1 || {
                echo "$(date) decide port check failed" >>/var/log/decide/service.log
                return 1
            }
        else
            echo "$(date) failed to run systemctl start decide" >>/var/log/decide/service.log
            return 1
        fi
    else
        if command -v service >/dev/null 2>&1; then
            if service decide start >>/var/log/decide/service.log 2>&1; then
                check_port localhost "${DECIDE_PORT}" >>/var/log/decide/service.log 2>&1 || {
                    echo "$(date) decide port check failed" >>/var/log/decide/service.log
                    return 1
                }
            else
                echo "$(date) failed to run service decide start" >>/var/log/decide/service.log
                return 1
            fi
        else
            echo "$(date) service command not found" >>/var/log/decide/service.log
            return 1
        fi
    fi
}

start_act() {
    mkdir -p /var/log/act
    if [ "$USE_SYSTEMCTL" -eq 1 ]; then
        if systemctl is-active --quiet act; then
            return 0
        fi
        if systemctl start act >>/var/log/act/service.log 2>&1; then
            if ! systemctl is-active --quiet act; then
                echo "$(date) act failed to start" >>/var/log/act/service.log
                return 1
            fi
            check_port localhost "${ACT_PORT}" >>/var/log/act/service.log 2>&1 || {
                echo "$(date) act port check failed" >>/var/log/act/service.log
                return 1
            }
        else
            echo "$(date) failed to run systemctl start act" >>/var/log/act/service.log
            return 1
        fi
    else
        if command -v service >/dev/null 2>&1; then
            if service act start >>/var/log/act/service.log 2>&1; then
                check_port localhost "${ACT_PORT}" >>/var/log/act/service.log 2>&1 || {
                    echo "$(date) act port check failed" >>/var/log/act/service.log
                    return 1
                }
            else
                echo "$(date) failed to run service act start" >>/var/log/act/service.log
                return 1
            fi
        else
            echo "$(date) service command not found" >>/var/log/act/service.log
            return 1
        fi
    fi
}

install_deps
start_bips
start_ng_siem
start_siem_ui
start_cicms
start_ng_soc
start_decide
start_act
