#!/bin/bash
set -euo pipefail

MAILBOX="${MAILBOX:-/var/mail/trainee}"
PHISHING_SENDER="${PHISHING_SENDER:-training_platform@example.com}"
MAIL_CONFIG="${MAIL_CONFIG:-/etc/trainee_mail.conf}"
BIPS_LOG="/var/log/bips/trainee.log"
NG_SIEM_LOG="/var/log/ng_siem/trainee.log"

log_both() {
    local msg="$1"
    mkdir -p "$(dirname "$BIPS_LOG")" "$(dirname "$NG_SIEM_LOG")"
    echo "$(date) $msg" >>"$BIPS_LOG"
    echo "$(date) $msg" >>"$NG_SIEM_LOG"
}

configure_mail_client() {
    mkdir -p "$(dirname "$MAIL_CONFIG")"
    printf "mailbox=%s\nsender=%s\n" "$MAILBOX" "$PHISHING_SENDER" >"$MAIL_CONFIG"
    log_both "Configured mail client with mailbox $MAILBOX"
}

download_test_messages() {
    mkdir -p "$(dirname "$MAILBOX")"
    cat <<EOF >>"$MAILBOX"
From: $PHISHING_SENDER
Subject: Security Training Exercise

This is a simulated phishing message. Please report if suspicious.
EOF
    log_both "Downloaded test message from $PHISHING_SENDER"
}

report_suspicious_emails() {
    if grep -qi "phishing" "$MAILBOX"; then
        log_both "Reported suspicious email to SOC"
    fi
}

configure_mail_client
download_test_messages
report_suspicious_emails
