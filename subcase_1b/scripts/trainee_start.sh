#!/bin/bash
set -euo pipefail

MAILBOX="${MAILBOX:-/var/mail/trainee}"
PHISHING_SENDER="${PHISHING_SENDER:-training_platform@example.com}"

check_mail() {
    mkdir -p "$(dirname "$MAILBOX")"
    printf "%s Received phishing email from %s\n" "$(date)" "$PHISHING_SENDER" >> "$MAILBOX"
}

check_mail
