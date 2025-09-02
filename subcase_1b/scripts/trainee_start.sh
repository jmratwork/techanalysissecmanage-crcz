#!/bin/bash
set -euo pipefail

TARGET="${TARGET:-10.10.0.4}"
SCAN_LOG="${SCAN_LOG:-/var/log/trainee/scans.log}"
INGEST_URL="${INGEST_URL:-http://localhost:5000/scan}"
SERVICE_DIR="$(dirname "$0")/../training_platform"
CLI="python $SERVICE_DIR/cli.py"
TRAINEE="${TRAINEE:-trainee}"
PASSWORD="${PASSWORD:-changeme}"
COURSE_ID="${COURSE_ID:-}"

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
    local apt_missing=()
    local snap_missing=()
    command -v nmap >/dev/null 2>&1 || apt_missing+=(nmap)
    command -v jq >/dev/null 2>&1 || apt_missing+=(jq)
    command -v gvm-script >/dev/null 2>&1 || apt_missing+=(gvm)
    command -v zaproxy >/dev/null 2>&1 || snap_missing+=(zaproxy)
    if [ ${#apt_missing[@]} -gt 0 ]; then
        apt_update_once || return 1
        export DEBIAN_FRONTEND=noninteractive
        if ! apt-get install -y "${apt_missing[@]}"; then
            echo "$(date) failed to install ${apt_missing[*]}" >&2
            return 1
        fi
    fi
    if [ ${#snap_missing[@]} -gt 0 ]; then
        apt_update_once || return 1
        export DEBIAN_FRONTEND=noninteractive
        if ! command -v snap >/dev/null 2>&1; then
            apt-get install -y snapd
            systemctl enable --now snapd.socket
            ln -s /var/lib/snapd/snap /snap || true
        fi
        snap install "${snap_missing[@]}" --classic
    fi
}

run_nmap_scan() {
    if result=$(nmap -p- "$TARGET" 2>&1); then
        printf '%s\n' "$result" >> "$SCAN_LOG"
        echo "$(date) Completed nmap scan against $TARGET" >> "$SCAN_LOG"
        send_results "$result"
    else
        echo "$(date) Nmap scan failed for $TARGET" >> "$SCAN_LOG"
    fi
}

run_openvas_scan() {
    if command -v gvm-script >/dev/null 2>&1; then
        if result=$(gvm-script --gmp-username admin --gmp-password admin socket /usr/share/gvm/scripts/quick-scan.gmp "$TARGET" 2>&1); then
            printf '%s\n' "$result" >> "$SCAN_LOG"
            echo "$(date) Completed OpenVAS scan against $TARGET" >> "$SCAN_LOG"
            send_results "$result"
        else
            echo "$(date) OpenVAS scan failed for $TARGET" >> "$SCAN_LOG"
        fi
    fi
}

run_zap_scan() {
    if command -v zaproxy >/dev/null 2>&1; then
        report=$(mktemp /tmp/zap-XXXX.html)
        if zaproxy -cmd -quickurl "http://$TARGET" -quickout "$report" >/dev/null 2>&1; then
            echo "$(date) Completed OWASP ZAP scan against $TARGET" >> "$SCAN_LOG"
            send_results "$(cat "$report")"
        else
            echo "$(date) OWASP ZAP scan failed for $TARGET" >> "$SCAN_LOG"
        fi
        rm -f "$report"
    fi
}

run_scans() {
    mkdir -p "$(dirname "$SCAN_LOG")"
    run_nmap_scan
    run_openvas_scan
    run_zap_scan
}

send_results() {
    local output="$1"
    if command -v curl >/dev/null 2>&1; then
        payload=$(jq -n --arg target "$TARGET" --arg output "$output" '{target:$target, output:$output}')
        curl -s -H "Content-Type: application/json" -X POST -d "$payload" "$INGEST_URL" >/dev/null 2>&1 || \
            echo "$(date) Failed to send scan results to $INGEST_URL" >> "$SCAN_LOG"
    fi
}

report_progress() {
    $CLI register --username "$TRAINEE" --password "$PASSWORD" --role trainee >/dev/null 2>&1 || true
    TOKEN="$($CLI login --username "$TRAINEE" --password "$PASSWORD")"
    if [ -z "$COURSE_ID" ]; then
        COURSE_ID="$($CLI list-courses --token "$TOKEN" | python -c 'import sys,json; data=json.load(sys.stdin); print(next(iter(data.keys()), ""))')"
    fi
    if [ -n "$COURSE_ID" ]; then
        $CLI update-progress --token "$TOKEN" --course-id "$COURSE_ID" --username "$TRAINEE" --progress 100 >/dev/null 2>&1 || true
    fi
}

install_deps
run_scans
report_progress
