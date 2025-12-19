#!/bin/bash
# Brightness indicator for waybar

BRIGHTNESS=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

# Font Awesome 6 icons
SUN=$'\uf185'
MOON=$'\uf186'

if [ "$BRIGHTNESS" -le 25 ]; then
    ICON="$MOON"
    COLOR="#6272a4"
elif [ "$BRIGHTNESS" -le 50 ]; then
    ICON="$SUN"
    COLOR="#f1fa8c"
elif [ "$BRIGHTNESS" -le 75 ]; then
    ICON="$SUN"
    COLOR="#ffb86c"
else
    ICON="$SUN"
    COLOR="#50fa7b"
fi

printf '{"text": "<span color=\\"%s\\">%s %s%%</span>"}\n' "$COLOR" "$ICON" "$BRIGHTNESS"
