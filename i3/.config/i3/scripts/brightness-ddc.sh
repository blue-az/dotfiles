#!/bin/bash
# Adjust brightness on external monitors via DDC/CI
# Usage: brightness-ddc.sh up|down [step]
# Note: Only monitor 2 (AL2216W) responds to brightness. Monitor 1 (XB271HU) doesn't.

direction="${1:-up}"
step="${2:-10}"

# Only display 2 works for brightness control
d=2

# Get current brightness (VCP 10)
current=$(ddcutil -d "$d" getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K\d+')

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
