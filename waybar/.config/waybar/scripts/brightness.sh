#!/bin/bash
# Monitor brightness via DDC/CI
# Note: Only display 2 (AL2216W) supports brightness control

BRIGHT=$(ddcutil -d 2 getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K\d+')

if [ -z "$BRIGHT" ]; then
    echo '{"text": "<span color=\"#ffffff\">BRT</span> <span color=\"#ff5555\"> N/A</span>", "class": "error"}'
else
    # Pad to 3 chars for consistent width
    printf '{"text": "<span color=\\"#ffffff\\">BRT</span> <span color=\\"#50fa7b\\">%3d%%</span>", "class": "normal"}\n' "$BRIGHT"
fi
