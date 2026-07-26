#!/bin/sh
# 2 screens: Left Acer (1680x1050) + Main Acer (2560x1440)
# Matches the boot default in ~/.config/sway/config.d/outputs.conf
. "$(dirname "$0")/sway-monitors.sh"

out "$TV4K" disable
out "$TV1080" disable
out "$LEFT" enable pos 0 390 res 1680x1050
out "$MAIN" enable pos 1680 0 mode 2560x1440@60Hz
