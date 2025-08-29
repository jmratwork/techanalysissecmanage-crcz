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
    local missing=()
    command -v rustscan >/dev/null 2>&1 || missing+=(rustscan)
    command -v jq >/dev/null 2>&1 || missing+=(jq)
    if [ ${#missing[@]} -gt 0 ]; then
        apt_update_once || return 1
        export DEBIAN_FRONTEND=noninteractive
        if ! apt-get install -y "${missing[@]}"; then
            echo "$(date) failed to install ${missing[*]}" >&2
            return 1
        fi
    fi
}

run_scan() {
    mkdir -p "$(dirname "$SCAN_LOG")"
    if result=$(rustscan -a "$TARGET" 2>&1); then
        printf '%s\n' "$result" >> "$SCAN_LOG"
        echo "$(date) Completed scan against $TARGET" >> "$SCAN_LOG"
        send_results "$result"
    else
        echo "$(date) Scan failed for $TARGET" >> "$SCAN_LOG"
    fi
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
run_scan
report_progress
