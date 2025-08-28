#!/bin/bash
set -euo pipefail

PHISHING_LOG="${PHISHING_LOG:-/var/log/training_platform/phishing.log}"
RECIPIENT="${RECIPIENT:-trainee@example.com}"

simulate_phishing_campaign() {
    mkdir -p "$(dirname "$PHISHING_LOG")"
    printf "%s Sending phishing email to %s\n" "$(date)" "$RECIPIENT" >> "$PHISHING_LOG"
}

simulate_phishing_campaign
