#!/usr/bin/env bash
# Super+T: raise the HEADLESS MONITOR wallpaper overlay onto the focused
# output (layer overlay, above windows). Press again to dismiss.
# Leaves the always-on wallpaper overlays (layer bottom) alone.
set -euo pipefail

POPDIR="${XDG_RUNTIME_DIR:-/tmp}/waybar-overlay-popup"

popup_pids() {
    pgrep -f "waybar -c ${POPDIR}/" || true
}

kill_popup() {
    local pids
    pids=$(popup_pids)
    if [[ -n "$pids" ]]; then
        # shellcheck disable=SC2086
        kill $pids 2>/dev/null || true
        sleep 0.2
        pids=$(popup_pids)
        if [[ -n "$pids" ]]; then
            # shellcheck disable=SC2086
            kill -9 $pids 2>/dev/null || true
        fi
    fi
}

if [[ -n "$(popup_pids)" ]]; then
    kill_popup
    exit 0
fi

focused=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused == true) | .name' | head -n1)
if [[ -z "$focused" ]]; then
    exit 1
fi

mkdir -p "$POPDIR"
jq --arg out "$focused" '.layer = "overlay" | .output = $out' \
    "$HOME/.config/waybar/config-overlay" >"$POPDIR/config-overlay"
jq --arg out "$focused" '.layer = "overlay" | .output = $out' \
    "$HOME/.config/waybar/config-monitor" >"$POPDIR/config-monitor"

waybar -c "$POPDIR/config-overlay" -s "$HOME/.config/waybar/style-overlay.css" \
    >>"$HOME/.local/share/waybar/overlay-popup.log" 2>&1 &
waybar -c "$POPDIR/config-monitor" -s "$HOME/.config/waybar/style-monitor.css" \
    >>"$HOME/.local/share/waybar/overlay-popup.log" 2>&1 &
disown
