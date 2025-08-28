#!/bin/bash
set -euo pipefail

PHISHING_LOG="${PHISHING_LOG:-/var/log/training_platform/phishing.log}"
RECIPIENT="${RECIPIENT:-trainee@example.com}"
BIPS_LOG="/var/log/bips/training_platform.log"
NG_SIEM_LOG="/var/log/ng_siem/training_platform.log"
PHISH_CONTENT="${PHISH_CONTENT:-/tmp/phish_mail.txt}"
SEND_DELAY_MINUTES="${SEND_DELAY_MINUTES:-1}"

log_both() {
    local msg="$1"
    mkdir -p "$(dirname "$BIPS_LOG")" "$(dirname "$NG_SIEM_LOG")"
    echo "$(date) $msg" >>"$BIPS_LOG"
    echo "$(date) $msg" >>"$NG_SIEM_LOG"
}

generate_phishing_email() {
    mkdir -p "$(dirname "$PHISHING_LOG")"
    cat <<EOF >"$PHISH_CONTENT"
From: training_platform@example.com
To: $RECIPIENT
Subject: Action Required: Security Update

Please review the attached document as soon as possible.
EOF
    echo "$(date) Generated phishing email for $RECIPIENT" >>"$PHISHING_LOG"
    log_both "Generated phishing template for $RECIPIENT"
}

schedule_phishing_email() {
    if command -v at >/dev/null 2>&1; then
        printf "%s\n" "printf '%s Delivered phishing email to %s\\n' \"\\$(date)\" \"$RECIPIENT\" >> \"$PHISHING_LOG\"" \
            | at now + "$SEND_DELAY_MINUTES" minutes >/dev/null 2>&1 || true
        log_both "Scheduled phishing email to $RECIPIENT using at for $SEND_DELAY_MINUTES minute(s)"
    else
        ( sleep "${SEND_DELAY_MINUTES}m"; printf "%s Delivered phishing email to %s\n" "$(date)" "$RECIPIENT" >>"$PHISHING_LOG" ) &
        log_both "Scheduled phishing email to $RECIPIENT with background job for $SEND_DELAY_MINUTES minute(s)"
    fi
}

generate_phishing_email
schedule_phishing_email
