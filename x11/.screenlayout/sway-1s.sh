#!/bin/sh
# Single screen - disable others, enable main
swaymsg output DP-1 disable
swaymsg output DP-3 disable
swaymsg output DP-2 enable pos 0 0 res 2560x1440
