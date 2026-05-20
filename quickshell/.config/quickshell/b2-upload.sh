#!/usr/bin/env bash
# Void Glow B2 uploader
# Usage: b2-upload.sh <category> <path>
#   <category>  - top-level bucket folder (Pictures, Videos, Documents, Code, HTB, Misc)
#   <path>      - file or directory to upload
# Writes a one-line status to ~/.cache/voidglow-b2-status that the
# Quickshell widget tails for the result line.

set -u
BUCKET="main-zua-backup"
STATUS="$HOME/.cache/voidglow-b2-status"
CREDS="$HOME/.config/b2/credentials"

write_status() { echo "$1" >"$STATUS"; }

# Credentials live OUTSIDE the repo (~/.config/b2/credentials).
# This is the secret-boundary design from Step 4.3 - script reads
# them at runtime, never bakes them in.
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

CATEGORY="${1:-}"
SRC="${2:-}"

if [ -z "$CATEGORY" ] || [ -z "$SRC" ]; then
  write_status "ERR: usage: b2-upload.sh <category> <path>"
  exit 1
fi
if [ ! -e "$SRC" ]; then
  write_status "ERR: not found: $SRC"
  exit 1
fi

BASENAME="$(basename "$SRC")"

if [ -f "$SRC" ]; then
  # Single file: upload to <bucket>/<category>/<filename>
  REMOTE="${CATEGORY}/${BASENAME}"
  write_status "Uploading $BASENAME -> $REMOTE ..."
  if b2 file upload --quiet "$BUCKET" "$SRC" "$REMOTE" >/dev/null 2>&1; then
    write_status "OK: $BASENAME -> $CATEGORY/"
  else
    write_status "ERR: upload failed: $BASENAME"
    exit 1
  fi

elif [ -d "$SRC" ]; then
  # Directory: recursive, preserve structure under <category>/<dirname>/
  # SAFETY: b2 sync by default *deletes* remote files not present locally.
  # For an "upload zone" we never want that. The flags below make sync
  # upload-only (no remote deletions), regardless of local state.
  REMOTE="${CATEGORY}/${BASENAME}"
  write_status "Syncing $BASENAME -> $REMOTE/ ..."
  if b2 sync \
    --no-progress \
    --keep-days 0 \
    --skip-newer \
    "$SRC" "b2://${BUCKET}/${REMOTE}" >/dev/null 2>&1; then
    write_status "OK: $BASENAME/ -> $CATEGORY/"
  else
    # Fallback flag set for older b2 CLIs that name flags differently
    if b2 sync --noProgress --keepDays 0 --skipNewer \
      "$SRC" "b2://${BUCKET}/${REMOTE}" >/dev/null 2>&1; then
      write_status "OK: $BASENAME/ -> $CATEGORY/"
    else
      write_status "ERR: sync failed: $BASENAME/"
      exit 1
    fi
  fi

else
  write_status "ERR: not a file or dir: $SRC"
  exit 1
fi
