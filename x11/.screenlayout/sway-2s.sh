#!/bin/sh
# 2 screens: XB271HU is output 1; AL2216W is output 2. Disable both LG TVs.
. "$(dirname "$0")/sway-monitors.sh"

out "$TV4K" disable
out "$TV1080" disable
out "$MAIN" enable pos 1680 0 mode 2560x1440@144Hz
out "$LEFT" enable pos 0 390 res 1680x1050

# Output assignments in outputs.conf guide new workspaces, but do not relocate
# workspaces that already exist. Put the two numbered workspaces on their
# intended displays whenever this layout is applied.
swaymsg "workspace number 1; move workspace to output $MAIN"
swaymsg "workspace number 2; move workspace to output $LEFT"
swaymsg 'workspace number 1'
