#!/bin/sh
# 3 screens Plus: LG SSCR2 4K (HDMI-A-1) + Left (DP-3) + Main (DP-2)
# Pin 4K to 60Hz — bare `res 3840x2160` prefers 120Hz and overloads multi-monitor bandwidth
swaymsg output DP-1 disable
swaymsg output HDMI-A-1 enable pos 0 0 mode 3840x2160@60Hz
swaymsg output DP-3 enable pos 3840 1095 res 1680x1050
swaymsg output DP-2 enable pos 5520 705 mode 2560x1440@60Hz
