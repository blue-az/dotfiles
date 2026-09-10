#!/bin/bash
# popup-clip.sh -- toggle CLIP/PRIM preview via dunst (no watch, no menu, no focus trap).
# $mod+c -> clip. $mod+Control_R (physical ;) -> prim. Do not bind $mod+0.

target="${1:-clip}"
case "$target" in
    clip) label="CLIP"; flags=() ;;
    prim) label="PRIM"; flags=(--primary) ;;
    *) exit 0 ;;
esac

IDFILE="${XDG_RUNTIME_DIR:-/tmp}/clip-preview-${target}.id"
LOG=/tmp/clip-preview.log
echo "--- $(date +%H:%M:%S) target=$target ---" >>"$LOG"

displayed() {
    dunstctl count displayed 2>/dev/null | awk 'NF {print $NF; exit}'
}

if [ -f "$IDFILE" ]; then
    old_id="$(cat "$IDFILE" 2>/dev/null || true)"
    if [ -n "$old_id" ]; then
        before="$(displayed)"
        before="${before:-0}"
        dunstctl close "$old_id" >>"$LOG" 2>&1 || true
        after="$(displayed)"
        after="${after:-0}"
        rm -f "$IDFILE"
        echo "toggle-close id=$old_id before=$before after=$after" >>"$LOG"
        if [ "$after" -lt "$before" ] 2>/dev/null; then
            exit 0
        fi
    fi
fi

raw="$(wl-paste "${flags[@]}" --no-newline 2>/dev/null || true)"
if [ -z "$raw" ]; then
    preview="(empty)"
else
    preview="$(printf '%s' "$raw" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-120)"
fi
echo "preview=${preview}" >>"$LOG"

id="$(
    /usr/bin/dunstify \
        --app-name="clip-preview" \
        --urgency=normal \
        --expire-time=0 \
        --print-id \
        --hints=string:x-dunst-stack-tag:clip-preview-${target} \
        "$label" "$preview" 2>>"$LOG"
)"
echo "dunstify_id=${id}" >>"$LOG"
printf '%s\n' "$id" >"$IDFILE"
