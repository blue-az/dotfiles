#!/bin/bash
pkill -f "waybar.*config-overlay" 2>/dev/null
sleep 0.3
exec waybar -c ~/.config/waybar/config-overlay -s ~/.config/waybar/style-overlay.css
