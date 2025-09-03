#!/usr/bin/env bash
# Create an Open edX cohort, generate invite codes, and register participants with KYPO.
# Usage: subcase_1b/scripts/enrol_instructor.sh COURSE_ID email1 [email2 ...]

set -euo pipefail

OPENEDX_API="${OPENEDX_API:-http://localhost:18000}"
OPENEDX_TOKEN="${OPENEDX_TOKEN:?Open edX token not set}"
INVITES_API="${INVITES_API:-http://localhost:5000}"
COHORT_NAME="${COHORT_NAME:-instructors}"
KYPO_API="${KYPO_API:-}"
KYPO_LIST_FILE="${KYPO_LIST_FILE:-kypo_participants.txt}"

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 COURSE_ID email..." >&2
  exit 1
fi

course_id=$1
shift

# Create cohort
curl -sS -X POST "${OPENEDX_API}/api/cohorts/" \
  -H "Authorization: Bearer ${OPENEDX_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"${COHORT_NAME}\", \"course_id\": \"${course_id}\"}" >/dev/null

for email in "$@"; do
  # Generate invite code
  invite_code=$(curl -sS -X POST "${INVITES_API}/invites" \
      -H "Content-Type: application/json" \
      -d "{\"email\": \"${email}\", \"course_id\": \"${course_id}\"}" \
      | python -c 'import sys, json; print(json.load(sys.stdin)["code"])')

  if [ -n "${MAIL_CMD:-}" ]; then
    printf 'Invite code: %s\n' "$invite_code" | ${MAIL_CMD} "$email"
  else
    echo "$email: $invite_code"
  fi

  if [ -n "$KYPO_API" ]; then
    curl -sS -X POST "${KYPO_API}/participants" \
      -H "Content-Type: application/json" \
      -d "{\"email\": \"${email}\", \"course_id\": \"${course_id}\"}" >/dev/null
  else
    echo "$email" >> "$KYPO_LIST_FILE"
  fi
done
