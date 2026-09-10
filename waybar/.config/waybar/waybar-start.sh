#!/bin/bash
# Robust waybar launcher for desktop (multi-monitor) and laptops.
# Replaces the inline exec_always + start-overlay.sh combo.
set -euo pipefail

LOGDIR="$HOME/.local/share/waybar"
mkdir -p "$LOGDIR"

# Kill any existing instances (exact + config-specific)
pkill -x waybar 2>/dev/null || true
pkill -f 'waybar.*config-(overlay|monitor)' 2>/dev/null || true
sleep 0.4

# Main bottom bar (all modules, all outputs)
waybar \
    >>"$LOGDIR/main.log" 2>&1 &

# Top overlay (sysinfo)
waybar -c "$HOME/.config/waybar/config-overlay" \
       -s "$HOME/.config/waybar/style-overlay.css" \
    >>"$LOGDIR/overlay.log" 2>&1 &

# Top monitor info overlay
waybar -c "$HOME/.config/waybar/config-monitor" \
       -s "$HOME/.config/waybar/style-monitor.css" \
    >>"$LOGDIR/monitor.log" 2>&1 &

disown
echo "waybar instances started (logs in $LOGDIR)"