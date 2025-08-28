#!/bin/bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/vuln}"
WEB_PORT="${WEB_PORT:-8080}"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        apt-get update -y
        apt-get install -y python3
    fi
}

configure_web() {
    mkdir -p "$WEB_ROOT"
    echo '<html><body>Intentionally vulnerable app</body></html>' > "$WEB_ROOT/index.html"
}

start_web() {
    python3 -m http.server "$WEB_PORT" --directory "$WEB_ROOT" >/var/log/vuln_web.log 2>&1 &
}

install_deps
configure_web
start_web
