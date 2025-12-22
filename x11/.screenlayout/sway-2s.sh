#!/bin/sh
# 2 screens: Left (DP-3 1680x1050) + Main (DP-2 2560x1440)
swaymsg output DP-1 disable
swaymsg output HDMI-A-1 disable
swaymsg output DP-3 enable pos 0 390 res 1680x1050
swaymsg output DP-2 enable pos 1680 0 res 2560x1440
