#!/bin/bash
# Laptop panel brightness via brightnessctl

BRIGHT=$(brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -d '%')

if [ -z "$BRIGHT" ]; then
    echo '{"text": "<span color=\"#ffffff\">BRT</span> <span color=\"#ff5555\"> N/A</span>", "class": "error"}'
else
    # Pad to 3 chars for consistent width
    printf '{"text": "<span color=\\"#ffffff\\">BRT</span> <span color=\\"#50fa7b\\">%3d%%</span>", "class": "normal"}\n' "$BRIGHT"
fi
