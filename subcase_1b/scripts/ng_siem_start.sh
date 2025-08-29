#!/bin/bash
set -euo pipefail

ATTACH_DIR="${ATTACH_DIR:-/opt/attachments}"
SIEM_LOG="${SIEM_LOG:-/var/log/ng_siem/ingest.log}"
PLAYBOOK="${PLAYBOOK:-/opt/playbooks/ca_cnd.yml}"
MONGO_URI="${MONGO_URI:-mongodb://localhost:27017}"
MONGO_DB="${MONGO_DB:-ng_siem}"
MONGO_COLLECTION="${MONGO_COLLECTION:-results}"

log_attachments() {
    mkdir -p "$(dirname "$SIEM_LOG")"
    if [ -d "$ATTACH_DIR" ]; then
        for file in "$ATTACH_DIR"/*; do
            [ -f "$file" ] || continue
            echo "$(date) Registered attachment ${file##*/}" >> "$SIEM_LOG"
        done
    else
        echo "$(date) Attachment directory $ATTACH_DIR not found" >> "$SIEM_LOG"
    fi
}

execute_playbook() {
    local result_file
    result_file=$(mktemp)
    if command -v ca_module >/dev/null 2>&1; then
        if ca_module --playbook "$PLAYBOOK" > "$result_file" 2>&1; then
            echo "$(date) CA/CND Playbook executed" >> "$SIEM_LOG"
        else
            echo "$(date) CA/CND Playbook execution failed" >> "$SIEM_LOG"
        fi
    else
        echo "$(date) ca_module command not found" >> "$SIEM_LOG"
        echo "ca_module command not found" > "$result_file"
    fi
    store_results "$result_file"
    rm -f "$result_file"
}

store_results() {
    local file="$1"
    if command -v mongo >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        mongo "$MONGO_URI/$MONGO_DB" --quiet --eval \
            "db.$MONGO_COLLECTION.insert({timestamp: new Date(), output: $(jq -Rs . \"$file\")})" >> "$SIEM_LOG" 2>&1
    else
        echo "$(date) mongo or jq command not found; results stored locally" >> "$SIEM_LOG"
        cat "$file" >> "$SIEM_LOG"
    fi
}

log_attachments
execute_playbook
