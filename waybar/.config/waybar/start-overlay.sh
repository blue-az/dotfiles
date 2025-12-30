#!/bin/bash
pkill -f "waybar.*config-overlay" 2>/dev/null
pkill -f "waybar.*config-monitor" 2>/dev/null
sleep 0.3
waybar -c ~/.config/waybar/config-overlay -s ~/.config/waybar/style-overlay.css &
waybar -c ~/.config/waybar/config-monitor -s ~/.config/waybar/style-monitor.css &
