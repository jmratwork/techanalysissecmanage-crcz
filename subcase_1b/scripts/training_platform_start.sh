#!/bin/bash
set -euo pipefail

SERVICE_DIR="$(dirname "$0")/../training_platform"
CLI="python $SERVICE_DIR/cli.py"
INSTRUCTOR="${INSTRUCTOR:-instructor}"
PASSWORD="${PASSWORD:-changeme}"
COURSE_NAME="${COURSE_NAME:-PenTest 101}"
COURSE_CONTENT="${COURSE_CONTENT:-Introduction to penetration testing}"
LOG_FILE="${LOG_FILE:-/var/log/training_platform/courses.log}"

# refuse to run with an insecure default instructor password
if [ "$PASSWORD" = "changeme" ]; then
    echo "ERROR: Set PASSWORD to a non-default value before starting the training platform." >&2
    exit 1
fi

mkdir -p "$(dirname "$LOG_FILE")"

# start service in background
python "$SERVICE_DIR/app.py" >/tmp/training_platform_server.log 2>&1 &
sleep 1

# register instructor if needed and obtain token
$CLI register --username "$INSTRUCTOR" --password "$PASSWORD" --role instructor >/dev/null 2>&1 || true
TOKEN="$($CLI login --username "$INSTRUCTOR" --password "$PASSWORD")"

# create course via API
$CLI create-course --token "$TOKEN" --title "$COURSE_NAME" --content "$COURSE_CONTENT"
echo "$(date) Instructor $INSTRUCTOR created course $COURSE_NAME" >> "$LOG_FILE"
