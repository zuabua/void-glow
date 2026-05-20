#!/usr/bin/env bash
# Toggle the Quickshell B2 drop-zone popup via its state file.
STATE="$HOME/.cache/voidglow-b2-shown"
[ -f "$STATE" ] || echo "0" >"$STATE"
if [ "$(cat "$STATE")" = "1" ]; then
  echo "0" >"$STATE"
else
  echo "1" >"$STATE"
fi
