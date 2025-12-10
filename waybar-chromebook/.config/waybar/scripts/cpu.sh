#!/bin/bash
# CPU usage and temperature for Chromebook (ARM/Rockchip)

CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)

# Get temperature from thermal zone (millicelsius)
TEMPC=$(awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
TEMPC=${TEMPC:-0}
TEMP=$((TEMPC * 9 / 5 + 32))

# No power reading available on this ARM chromebook
WATTS=""

# Determine color based on temperature
if [ $TEMPC -gt 80 ]; then
    COLOR="#ff5555"
    CLASS="critical"
elif [ $TEMPC -gt 65 ]; then
    COLOR="#f1fa8c"
    CLASS="warning"
else
    COLOR="#50fa7b"
    CLASS="normal"
fi

# Output JSON for waybar with pango markup
printf '{"text": "<span color=\\"#ffffff\\">CPU</span> <span color=\\"%s\\"> %3d%% %3d°</span>", "class": "%s"}\n' "$COLOR" "$CPU" "$TEMP" "$CLASS"
