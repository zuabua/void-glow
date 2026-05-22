#!/usr/bin/env bash
# Void Glow — SDDM background generator.
# Renders a 2560x1440 background from the palette in colors.sh.
# Re-run any time to regenerate; output is committed but reproducible.

set -e
OUT="$(dirname "$0")/background.png"

# Pull palette - sourced so values live in ONE place (colors.sh).
# Note: source path assumes the theme dir is at its repo location.
# If colors.sh moves, update this. On bare metal, install.sh resolves it.
PALETTE="${HOME}/void-glow/theme/.config/theme/colors.sh"
if [ -r "$PALETTE" ]; then
  # shellcheck disable=SC1090
  source "$PALETTE"
else
  # Fallback to literal values - keeps the script standalone-runnable.
  VOID_BASE="#0d0d0f"
  VOID_ACCENT_TEAL="#5eead4"
  VOID_ACCENT_INDIGO="#818cf8"
fi

W=2560
H=1440

# 1. Base — solid VOID_BASE.
# 2. Teal radial — large, soft, bottom-left origin, low alpha.
# 3. Indigo radial — smaller, softer, top-right, even lower alpha.
# 4. Noise — fine grain, very low opacity, kills banding.
#
# ImageMagick's -fx and gradient composites do this in one pipeline.

magick -size "${W}x${H}" \
  xc:"${VOID_BASE}" \
  \( -size "${W}x${H}" radial-gradient:"${VOID_ACCENT_TEAL}-none" \
  -gravity SouthWest -extent "${W}x${H}" \
  -evaluate multiply 0.18 \) -compose Screen -composite \
  \( -size "${W}x${H}" radial-gradient:"${VOID_ACCENT_INDIGO}-none" \
  -gravity NorthEast -extent "${W}x${H}" \
  -evaluate multiply 0.10 \) -compose Screen -composite \
  \( -size "${W}x${H}" xc:gray50 +noise random -channel R -separate +channel \
  -evaluate multiply 0.04 \) -compose Screen -composite \
  "$OUT"

echo "Generated: $OUT"
