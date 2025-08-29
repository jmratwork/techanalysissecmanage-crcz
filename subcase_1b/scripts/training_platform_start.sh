#!/bin/bash
set -euo pipefail

COURSE_DIR="${COURSE_DIR:-/var/courses}"
COURSE_NAME="${COURSE_NAME:-PenTest 101}"
LOG_FILE="${LOG_FILE:-/var/log/training_platform/courses.log}"
RANGE_SCENARIO_DIR="${RANGE_SCENARIO_DIR:-/var/cyber_range}"

create_course() {
    mkdir -p "$COURSE_DIR"
    mkdir -p "$(dirname "$LOG_FILE")"
    local course_file="$COURSE_DIR/${COURSE_NAME// /_}.md"
    echo "# $COURSE_NAME\nThis course covers penetration testing and vulnerability assessment." > "$course_file"
    echo "$(date) Created course $COURSE_NAME at $course_file" >> "$LOG_FILE"
}

prepare_cyber_range() {
    mkdir -p "$RANGE_SCENARIO_DIR"
    echo "$(date) Prepared cyber range scenario directory at $RANGE_SCENARIO_DIR" >> "$LOG_FILE"
}

create_course
prepare_cyber_range
