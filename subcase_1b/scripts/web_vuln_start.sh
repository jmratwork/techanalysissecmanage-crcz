#!/bin/bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/dvwa}"
WEB_PORT="${WEB_PORT:-8080}"
LOG_DIR="/var/log/web_vuln"

# Location of the Ansible inventory used to populate defaults when
# environment variables are not provided.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_FILE="${INVENTORY_FILE:-$SCRIPT_DIR/../ansible/inventory.ini}"

load_inventory_var() {
    local key="$1"
    if [ -f "$INVENTORY_FILE" ]; then
        local host_line
        host_line=$(grep '^web_vuln' "$INVENTORY_FILE" || true)
        if [[ $host_line =~ $key=([^[:space:]]+) ]]; then
            echo "${BASH_REMATCH[1]}"
        fi
    fi
}

DVWA_REPO="${DVWA_REPO:-$(load_inventory_var dvwa_repo)}"
DVWA_ARCHIVE="${DVWA_ARCHIVE:-$(load_inventory_var dvwa_archive)}"

if [ -z "${DVWA_ARCHIVE:-}" ]; then
    DEFAULT_ARCHIVE="$SCRIPT_DIR/../dvwa.tar.gz"
    [ -f "$DEFAULT_ARCHIVE" ] && DVWA_ARCHIVE="$DEFAULT_ARCHIVE"
fi

install_deps() {
    if [ "${SKIP_INSTALL:-0}" -eq 1 ]; then
        return
    fi

    apt-get update -y
    apt-get install -y git php php-mysqli
}

fetch_dvwa() {
    if [ -d "$WEB_ROOT" ]; then
        return
    fi

    if [ -n "${DVWA_ARCHIVE:-}" ] && [ -f "$DVWA_ARCHIVE" ]; then
        mkdir -p "$(dirname "$WEB_ROOT")"
        tar -xzf "$DVWA_ARCHIVE" -C "$(dirname "$WEB_ROOT")"
    elif [ -n "${DVWA_REPO:-}" ]; then
        git clone "$DVWA_REPO" "$WEB_ROOT"
    else
        echo "DVWA source not provided. Set DVWA_ARCHIVE or DVWA_REPO." >&2
        exit 1
    fi

    if [ ! -f "$WEB_ROOT/config/config.inc.php" ] && [ -f "$WEB_ROOT/config/config.inc.php.dist" ]; then
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
