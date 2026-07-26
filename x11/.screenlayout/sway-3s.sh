#!/bin/sh
# 3 screens: LG TV 1080p + Left Acer + Main Acer (4K TV off)
# The 1080p TV is unplugged and its identifier unknown, so its 1920px slot at
# the far left stays empty until TV1080 is filled in in sway-monitors.sh.
. "$(dirname "$0")/sway-monitors.sh"

out "$TV4K" disable
out "$TV1080" enable pos 0 375 res 1920x1080
out "$LEFT" enable pos 1920 390 res 1680x1050
out "$MAIN" enable pos 3600 0 mode 2560x1440@60Hz
