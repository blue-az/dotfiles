#!/bin/bash
# Battery status for Chromebook (sbs-9-000b battery)

BAT_PATH="/sys/class/power_supply/sbs-9-000b"

[ ! -d "$BAT_PATH" ] && echo '{"text": ""}' && exit 0

CAP=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo 0)
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

# Font Awesome 6 battery icons (unicode)
FULL=$'\uf240'
THREE=$'\uf241'
HALF=$'\uf242'
QUARTER=$'\uf243'
EMPTY=$'\uf244'
BOLT=$'\uf0e7'

if [ "$STATUS" = "Charging" ]; then
    ICON="$BOLT"
    COLOR="#50fa7b"
elif [ "$STATUS" = "Full" ]; then
    ICON="$FULL"
    COLOR="#50fa7b"
elif [ $CAP -le 10 ]; then
    ICON="$EMPTY"
    COLOR="#ff5555"
elif [ $CAP -le 25 ]; then
    ICON="$QUARTER"
    COLOR="#ff5555"
elif [ $CAP -le 50 ]; then
    ICON="$HALF"
    COLOR="#f1fa8c"
elif [ $CAP -le 75 ]; then
    ICON="$THREE"
    COLOR="#f1fa8c"
else
    ICON="$FULL"
    COLOR="#50fa7b"
fi

printf '{"text": "<span color=\\"%s\\">%s %s%%</span>"}\n' "$COLOR" "$ICON" "$CAP"
