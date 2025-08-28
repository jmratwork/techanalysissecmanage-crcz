#!/bin/bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/dvwa}"
WEB_PORT="${WEB_PORT:-8080}"
DVWA_REPO="${DVWA_REPO:-https://internal.example.com/dvwa.git}"
LOG_DIR="/var/log/web_vuln"

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    apt-get update -y
    apt-get install -y git php php-mysqli
}

fetch_dvwa() {
    if [ ! -d "$WEB_ROOT" ]; then
        git clone "$DVWA_REPO" "$WEB_ROOT"
    fi

    if [ ! -f "$WEB_ROOT/config/config.inc.php" ]; then
        cp "$WEB_ROOT/config/config.inc.php.dist" "$WEB_ROOT/config/config.inc.php"
    fi
}

create_start_script() {
    mkdir -p "$LOG_DIR"
    cat > /usr/local/bin/run_dvwa.sh <<'SCRIPT'
#!/bin/bash
set -euo pipefail
WEB_ROOT="${WEB_ROOT:-/var/www/dvwa}"
WEB_PORT="${WEB_PORT:-8080}"
LOG_DIR="/var/log/web_vuln"
mkdir -p "$LOG_DIR"
cd "$WEB_ROOT"
php -S 0.0.0.0:"$WEB_PORT" index.php >>"$LOG_DIR/dvwa.log" 2>&1
SCRIPT
    chmod +x /usr/local/bin/run_dvwa.sh
}

start_dvwa() {
    /usr/local/bin/run_dvwa.sh &
}

install_deps
fetch_dvwa
create_start_script
start_dvwa
