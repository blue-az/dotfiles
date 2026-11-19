#!/usr/bin/env bash
# Toggle a compact TestBench-only readout as a Waybar overlay.
set -euo pipefail

POPDIR="${XDG_RUNTIME_DIR:-/tmp}/waybar-llm-readout"
CONFIG="$POPDIR/config-llm-readout"

popup_pids() {
    pgrep -f "^waybar -c ${CONFIG}([[:space:]]|$)" || true
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

outputs=$(swaymsg -t get_outputs -r)
focused=$(jq -r '.[] | select(.focused == true) | .name' <<<"$outputs" | head -n1)
[[ -n "$focused" ]] || exit 1
width=$(jq -r --arg out "$focused" '.[] | select(.name == $out) | .rect.width' <<<"$outputs")
mkdir -p "$POPDIR"
jq --arg out "$focused" '.layer = "overlay" | .output = $out' \
    "$HOME/.config/waybar/config-llm-readout" >"$CONFIG"
sed "s/@CENTER_OFFSET@/$((width / 2))px/" \
    "$HOME/.config/waybar/style-llm-readout.css" >"$POPDIR/style-llm-readout.css"
waybar -c "$CONFIG" -s "$POPDIR/style-llm-readout.css" \
    >>"$HOME/.local/share/waybar/llm-readout.log" 2>&1 &
disown
