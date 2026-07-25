#!/bin/sh
# Single screen - main Acer only
swaymsg output DP-1 disable
swaymsg output HDMI-A-1 disable
swaymsg output DP-3 disable
swaymsg output DP-2 enable pos 0 0 mode 2560x1440@60Hz
