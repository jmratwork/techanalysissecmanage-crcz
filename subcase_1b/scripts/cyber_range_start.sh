#!/bin/bash
set -euo pipefail

RANGE_LOG="${RANGE_LOG:-/var/log/cyber_range/launch.log}"
VULN_PROFILE="${VULN_PROFILE:-baseline}"
COMPOSE_FILE="$(dirname "$0")/../docker-compose.yml"

usage() {
    echo "Usage: $0 [--down]"
    echo "Deploy or tear down the cyber range environment using Docker Compose."
}

log() {
    mkdir -p "$(dirname "$RANGE_LOG")"
    echo "$(date) $1" >> "$RANGE_LOG"
}

deploy() {
    log "Launching cyber range with profile $VULN_PROFILE"
    if command -v docker >/dev/null 2>&1; then
        docker compose -f "$COMPOSE_FILE" up -d
    else
        log "docker command not found; skipping container launch"
    fi
}

teardown() {
    log "Stopping cyber range"
    if command -v docker >/dev/null 2>&1; then
        docker compose -f "$COMPOSE_FILE" down
    else
        log "docker command not found; nothing to stop"
    fi
}

case "${1:-up}" in
    --down|down)
        teardown
        ;;
    --help|-h)
        usage
        ;;
    *)
        deploy
        ;;
 esac
