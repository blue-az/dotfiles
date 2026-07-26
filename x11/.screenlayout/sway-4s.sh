#!/bin/sh
# 4 screens: LG SSCR2 4K + LG TV 1080p + Left Acer + Main Acer
# Pin 4K to 60Hz — bare `res 3840x2160` prefers 120Hz and overloads multi-monitor bandwidth
# The 1080p TV is unplugged and its identifier unknown, so its 1920px slot
# between the 4K and the left Acer stays empty until TV1080 is filled in in
# sway-monitors.sh - until then this is 3sp with a gap.
. "$(dirname "$0")/sway-monitors.sh"

out "$TV4K" enable pos 0 0 mode 3840x2160@60Hz
out "$TV1080" enable pos 3840 1080 res 1920x1080
out "$LEFT" enable pos 5760 1095 res 1680x1050
out "$MAIN" enable pos 7440 705 mode 2560x1440@60Hz
