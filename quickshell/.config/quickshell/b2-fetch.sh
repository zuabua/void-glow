#!/usr/bin/env bash
# Fetch a single file from the B2 bucket to a local destination.
# Usage: b2-fetch.sh <remote-path> <local-dest-dir>
#   <remote-path>     path INSIDE bucket (e.g. "Pictures/screenshot.png")
#   <local-dest-dir>  local directory to download into
# Saves as <local-dest-dir>/<basename of remote>. Won't overwrite.

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
DEST_DIR="${2:-}"

if [ -z "$REMOTE" ] || [ -z "$DEST_DIR" ]; then
  write_status "ERR: usage: b2-fetch.sh <remote-path> <local-dest-dir>"
  exit 1
fi

# Same path-sanity check as delete (defensive against shell metacharacters).
case "$REMOTE" in
*..* | *\** | *\?* | *\$* | *\`* | *\;*)
  write_status "ERR: invalid remote path"
  exit 1
  ;;
esac

if [ ! -d "$DEST_DIR" ]; then
  write_status "ERR: dest dir does not exist"
  exit 1
fi

BASENAME="$(basename "$REMOTE")"
LOCAL="${DEST_DIR%/}/${BASENAME}"

# Don't silently overwrite. If a same-named file already exists, refuse.
if [ -e "$LOCAL" ]; then
  write_status "ERR: would overwrite ${BASENAME}"
  exit 1
fi

write_status "Fetching ${BASENAME} ..."
if b2 file download --quiet "b2://${BUCKET}/${REMOTE}" "$LOCAL" >/dev/null 2>&1; then
  write_status "OK: fetched ${BASENAME} -> ${DEST_DIR%/}"
else
  write_status "ERR: fetch failed: ${BASENAME}"
  exit 1
fi
