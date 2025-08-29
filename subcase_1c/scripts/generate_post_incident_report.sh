#!/bin/bash
set -euo pipefail

# Determine repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REPORT_DIR="$REPO_ROOT/reports"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
REPORT_FILE="$REPORT_DIR/post_incident_report_$TIMESTAMP.txt"

# Default log locations (can be overridden by environment variables)
NG_SIEM_LOG=${NG_SIEM_LOG:-/var/log/ngsiem.log}
BIPS_LOG=${BIPS_LOG:-/var/log/bips.log}
ACT_LOG=${ACT_LOG:-/var/log/act.log}

mkdir -p "$REPORT_DIR"

{
  echo "Post-Incident Report - $TIMESTAMP"
  echo "================================"

  collect_log() {
    local name="$1"; local path="$2"
    echo ""
    if [[ -f "$path" ]]; then
      echo "=== $name Logs ($path) ==="
      tail -n 100 "$path"
    else
      echo "=== $name Logs not found at $path ==="
    fi
  }

  collect_log "NG-SIEM" "$NG_SIEM_LOG"
  collect_log "BIPS" "$BIPS_LOG"
  collect_log "Act" "$ACT_LOG"
} > "$REPORT_FILE"

echo "Report generated at $REPORT_FILE"
