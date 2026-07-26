#!/bin/sh
# 3 screens Plus: LG SSCR2 4K + Left Acer + Main Acer (1080p TV off)
# Pin 4K to 60Hz — bare `res 3840x2160` prefers 120Hz and overloads multi-monitor bandwidth
. "$(dirname "$0")/sway-monitors.sh"

out "$TV1080" disable
out "$TV4K" enable pos 0 0 mode 3840x2160@60Hz
out "$LEFT" enable pos 3840 1095 res 1680x1050
out "$MAIN" enable pos 5520 705 mode 2560x1440@60Hz
