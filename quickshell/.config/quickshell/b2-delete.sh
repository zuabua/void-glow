#!/usr/bin/env bash
# Delete a SINGLE file from the B2 bucket.
# Usage: b2-delete.sh <remote-path>
#   <remote-path>  - path INSIDE the bucket (e.g. "Misc/test.txt")
# SAFETY: only deletes ONE specific file. No recursion, no globs.
# Status to ~/.cache/voidglow-b2-status (same pattern as upload).

set -u
BUCKET="main-zua-backup"
STATUS="$HOME/.cache/voidglow-b2-status"
CREDS="$HOME/.config/b2/credentials"

write_status() { echo "$1" >"$STATUS"; }

if [ ! -r "$CREDS" ]; then
  write_status "ERR: missing $CREDS"
  exit 1
fi
# shellcheck disable=SC1090
source "$CREDS"
b2 account authorize "$B2_KEY_ID" "$B2_APP_KEY" >/dev/null 2>&1 || {
  write_status "ERR: b2 authorize failed"
  exit 1
}

REMOTE="${1:-}"
if [ -z "$REMOTE" ]; then
  write_status "ERR: usage: b2-delete.sh <remote-path>"
  exit 1
fi

# Reject anything with shell metacharacters or .. just to be safe.
case "$REMOTE" in
*..* | *\** | *\?* | *\$* | *\`* | *\;*)
  write_status "ERR: invalid path"
  exit 1
  ;;
esac

write_status "Deleting ${REMOTE} ..."
if b2 rm --quiet "b2://${BUCKET}/${REMOTE}" >/dev/null 2>&1; then
  write_status "OK: deleted ${REMOTE}"
else
  write_status "ERR: delete failed: ${REMOTE}"
  exit 1
fi
