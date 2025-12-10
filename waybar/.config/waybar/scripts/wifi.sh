#!/bin/bash
# WiFi SSID and signal strength with visual bars

# Only show on laptops with battery
[ ! -d /sys/class/power_supply/BAT0 ] && echo '{"text": ""}' && exit 0

IFACE=$(iw dev | awk '$1=="Interface"{print $2}' | head -1)

if [ -n "$IFACE" ]; then
    SSID=$(iw dev "$IFACE" link 2>/dev/null | awk '/SSID:/{$1=""; print substr($0,2)}')
    SIGNAL=$(iw dev "$IFACE" link 2>/dev/null | awk '/signal:/{print $2}')

    if [ -n "$SIGNAL" ]; then
        SIG=${SIGNAL%.*}

        if [ $SIG -ge -50 ]; then
            BARS="▁▂▃▄▅"
            COLOR="#50fa7b"
            CLASS="excellent"
        elif [ $SIG -ge -60 ]; then
            BARS="▁▂▃▄ "
            COLOR="#50fa7b"
            CLASS="good"
        elif [ $SIG -ge -70 ]; then
            BARS="▁▂▃  "
            COLOR="#f1fa8c"
            CLASS="warning"
        elif [ $SIG -ge -80 ]; then
            BARS="▁▂   "
            COLOR="#f1fa8c"
            CLASS="warning"
        else
            BARS="▁    "
            COLOR="#ff5555"
            CLASS="critical"
        fi

        printf '{"text": "<span color=\\"%s\\">%s %s %sdBm</span>", "class": "%s"}\n' "$COLOR" "$SSID" "$BARS" "$SIG" "$CLASS"
    else
        echo '{"text": "<span color=\"#ff5555\">no wifi</span>", "class": "critical"}'
    fi
else
    echo '{"text": "<span color=\"#ff5555\">no wifi</span>", "class": "critical"}'
fi
