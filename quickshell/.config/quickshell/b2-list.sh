#!/usr/bin/env bash
# Refresh the cached B2 bucket listing.
# Usage: b2-list.sh
# Writes contents to ~/.cache/voidglow-b2-list (one remote path per line).
# Widget reads/watches that file to render the manage panel.

set -u
BUCKET="main-zua-backup"
CACHE="$HOME/.cache/voidglow-b2-list"
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

write_status "Listing bucket..."

# b2 ls --recursive prints one path per line. We capture to a tmp file
# then move atomically so the widget never reads a half-written file.
TMP="$(mktemp "${CACHE}.XXXXXX")"
if b2 ls --recursive "b2://${BUCKET}" >"$TMP" 2>/dev/null; then
  mv "$TMP" "$CACHE"
  COUNT=$(wc -l <"$CACHE")
  write_status "OK: listed ${COUNT} items"
else
  rm -f "$TMP"
  write_status "ERR: listing failed"
  exit 1
fi
