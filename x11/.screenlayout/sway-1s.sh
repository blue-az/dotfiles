#!/bin/sh
# Single screen - main Acer only
# Leave fullscreen workspaces on the output that will remain active.  Otherwise
# disabling the TV can leave Sway displaying an empty fullscreen surface.
swaymsg workspace 1
. "$(dirname "$0")/sway-monitors.sh"

out "$TV4K" disable
out "$TV1080" disable
out "$LEFT" disable
out "$MAIN" enable pos 0 0 mode 2560x1440@60Hz
