#!/bin/sh
# 4 screens: LG SSCR2 4K (HDMI-A-1) + LG TV (DP-1) + Left (DP-3) + Main (DP-2)
swaymsg output HDMI-A-1 enable pos 0 0 res 3840x2160
swaymsg output DP-1 enable pos 3840 1080 res 1920x1080
swaymsg output DP-3 enable pos 5760 1095 res 1680x1050
swaymsg output DP-2 enable pos 7440 705 res 2560x1440
