#!/bin/bash
# WiFi SSID and signal strength for Chromebook

BAT_PATH="/sys/class/power_supply/sbs-9-000b"
[ ! -d "$BAT_PATH" ] && echo '{"text": ""}' && exit 0

# Get WiFi info using nmcli (more reliable on this system)
SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep "^yes:" | cut -d: -f2)

if [ -n "$SSID" ]; then
    # Get signal strength
    SIGNAL=$(nmcli -t -f active,signal dev wifi 2>/dev/null | grep "^yes:" | cut -d: -f2)
    SIGNAL=${SIGNAL:-0}

    if [ $SIGNAL -ge 80 ]; then
        BARS="▁▂▃▄▅"
        COLOR="#50fa7b"
        CLASS="excellent"
    elif [ $SIGNAL -ge 60 ]; then
        BARS="▁▂▃▄ "
        COLOR="#50fa7b"
        CLASS="good"
    elif [ $SIGNAL -ge 40 ]; then
        BARS="▁▂▃  "
        COLOR="#f1fa8c"
        CLASS="warning"
    elif [ $SIGNAL -ge 20 ]; then
        BARS="▁▂   "
        COLOR="#f1fa8c"
        CLASS="warning"
    else
        BARS="▁    "
        COLOR="#ff5555"
        CLASS="critical"
    fi

    printf '{"text": "<span color=\\"%s\\">%s %s %s%%</span>", "class": "%s"}\n' "$COLOR" "$SSID" "$BARS" "$SIGNAL" "$CLASS"
else
    echo '{"text": "<span color=\\"#ff5555\\">no wifi</span>", "class": "critical"}'
fi
