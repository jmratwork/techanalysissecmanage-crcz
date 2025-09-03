#!/bin/bash
set -euo pipefail

TARGET="${TARGET:-10.10.0.4}"
CALDERA_SERVER="${CALDERA_SERVER:-http://localhost:8888}"
LOG_DIR="${LOG_DIR:-/var/log/trainee}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/lab_runner.log}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            TARGET="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--target IP]" >&2
            exit 1
            ;;
    esac
done

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

log() {
    echo "$(date) $1" | tee -a "$LOG_FILE"
}

run_profile() {
    local name="$1"
    local cmd="$2"
    shift 2
    local args=("$@")
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "$name skipped (missing $cmd)"
        return 0
    fi
    log "Running $name"
    if "$cmd" "${args[@]}" >>"$LOG_FILE" 2>&1; then
        log "$name completed"
    else
        log "$name failed"
    fi
}

run_profile "Reconnaissance sweep" nmap -sV -O "$TARGET"
run_profile "Full TCP scan" nmap -p- "$TARGET"
run_profile "OpenVAS quick scan" gvm-script --gmp-username admin --gmp-password admin socket /usr/share/gvm/scripts/quick-scan.gmp "$TARGET"
run_profile "OWASP ZAP quick scan" zaproxy -cmd -quickurl "http://$TARGET" -quickout "$LOG_DIR/zap.html"

if command -v curl >/dev/null 2>&1; then
    log "Starting Caldera operation"
    agent=$(mktemp /tmp/sandcat-XXXX)
    if curl -sf "$CALDERA_SERVER/file/download/sandcat.go?platform=linux&arch=amd64" -o "$agent"; then
        chmod +x "$agent"
        "$agent" -server "$CALDERA_SERVER" -group red >>"$LOG_FILE" 2>&1 &
        pid=$!
        sleep 5
        kill "$pid" >/dev/null 2>&1 || true
        log "Caldera operation triggered"
    else
        log "Caldera agent download failed"
    fi
    rm -f "$agent"
else
    log "Caldera step skipped (curl not found)"
fi

log "Lab run complete"
