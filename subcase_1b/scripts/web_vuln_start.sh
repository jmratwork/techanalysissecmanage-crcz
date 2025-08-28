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
DVWA_ARCHIVE_CHECKSUM="${DVWA_ARCHIVE_CHECKSUM:-$(load_inventory_var dvwa_archive_checksum)}"
DVWA_GIT_COMMIT="${DVWA_GIT_COMMIT:-$(load_inventory_var dvwa_git_commit)}"

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

log_error() {
    mkdir -p "$LOG_DIR"
    echo "$1" | tee -a "$LOG_DIR/error.log" >&2
}

verify_checksum() {
    local file="$1"
    local expected="$2"
    [ -z "$expected" ] && return 0
    local algo="${expected%%:*}"
    local expected_hash="${expected#*:}"
    local actual_hash=""
    case "$algo" in
        sha256)
            actual_hash=$(sha256sum "$file" | awk '{print $1}')
            ;;
        sha1)
            actual_hash=$(sha1sum "$file" | awk '{print $1}')
            ;;
        md5)
            actual_hash=$(md5sum "$file" | awk '{print $1}')
            ;;
        *)
            log_error "Unsupported checksum algorithm: $algo"
            return 1
            ;;
    esac
    if [ "$actual_hash" != "$expected_hash" ]; then
        log_error "Checksum verification failed for $file"
        return 1
    fi
}

fetch_dvwa() {
    if [ -d "$WEB_ROOT" ]; then
        return
    fi

    if [ -n "${DVWA_ARCHIVE:-}" ] && [ -f "$DVWA_ARCHIVE" ]; then
        if ! verify_checksum "$DVWA_ARCHIVE" "$DVWA_ARCHIVE_CHECKSUM"; then
            exit 1
        fi
        mkdir -p "$(dirname "$WEB_ROOT")"
        tar -xzf "$DVWA_ARCHIVE" -C "$(dirname "$WEB_ROOT")"
    elif [ -n "${DVWA_REPO:-}" ]; then
        git clone "$DVWA_REPO" "$WEB_ROOT"
        if [ -n "${DVWA_GIT_COMMIT:-}" ]; then
            local actual_commit
            actual_commit=$(git -C "$WEB_ROOT" rev-parse HEAD)
            if [ "$actual_commit" != "$DVWA_GIT_COMMIT" ]; then
                log_error "DVWA repository commit mismatch"
                exit 1
            fi
        fi
    else
        log_error "DVWA source not provided. Set DVWA_ARCHIVE or DVWA_REPO."
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
