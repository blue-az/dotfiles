#!/bin/sh
# 3 screens: TV (DP-1) + Left (DP-3) + Main (DP-2)
swaymsg output DP-1 enable pos 0 375 res 1920x1080
swaymsg output DP-3 enable pos 1920 390 res 1680x1050
swaymsg output DP-2 enable pos 3600 0 mode 2560x1440@60Hz
