#!/bin/bash
# Adjust brightness on external monitors via DDC/CI
# Usage: brightness-ddc.sh up|down [step]
# Note: Only monitor 2 (AL2216W) responds to brightness. Monitor 1 (XB271HU) doesn't.

direction="${1:-up}"
step="${2:-10}"

# Only display 2 works for brightness control
d=2

# Get current brightness (VCP 10)
current=$(
    ddcutil -d "$d" getvcp 10 2>/dev/null \
        | awk -F'current value =|,' 'NF>1 {gsub(/[^0-9]/, "", $2); print $2; exit}'
)

if [ -z "$current" ]; then
    exit 1
fi

if [ "$direction" = "up" ]; then
    new=$((current + step))
    [ $new -gt 100 ] && new=100
else
    new=$((current - step))
    [ $new -lt 0 ] && new=0
fi

ddcutil -d "$d" setvcp 10 "$new" 2>/dev/null

# Force immediate waybar brightness module refresh.
pkill -RTMIN+8 waybar 2>/dev/null || true

# Optional feedback to avoid confusion: this adjusts monitor 2 only.
if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "brightness-ddc" "Monitor 2 brightness" "${new}%"
fi
