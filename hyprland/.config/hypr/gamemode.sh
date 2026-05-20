#!/usr/bin/env bash
# Void Glow gamemode toggle.
# Disables compositor eye-candy for performance, or restores it.
# State persisted at ~/.cache/voidglow-gamemode (0=off, 1=on).
# Triggered by Hyprland keybind AND Waybar button (one script, two callers).

STATE="$HOME/.cache/voidglow-gamemode"
[ -f "$STATE" ] || echo "0" >"$STATE"
CURRENT="$(cat "$STATE")"

if [ "$CURRENT" = "1" ]; then
  # ── Turning OFF: restore the visual config ───────────────
  hyprctl --batch "\
    keyword animations:enabled 1 ;\
    keyword decoration:blur:enabled 1 ;\
    keyword decoration:shadow:enabled 1 ;\
    keyword decoration:rounding 8 ;\
    keyword misc:vfr 1 ;\
    keyword misc:vrr 0" >/dev/null
  echo "0" >"$STATE"
  notify-send -t 1500 "Void Glow" "Gamemode OFF — visuals restored"
else
  # ── Turning ON: kill everything that costs frames ────────
  hyprctl --batch "\
    keyword animations:enabled 0 ;\
    keyword decoration:blur:enabled 0 ;\
    keyword decoration:shadow:enabled 0 ;\
    keyword decoration:rounding 0 ;\
    keyword misc:vfr 0 ;\
    keyword misc:vrr 1" >/dev/null
  echo "1" >"$STATE"
  notify-send -t 1500 "Void Glow" "Gamemode ON — performance mode engaged"
fi
