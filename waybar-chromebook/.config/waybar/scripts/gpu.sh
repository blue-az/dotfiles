#!/bin/bash
# GPU usage and temperature for Chromebook (Rockchip Mali ff9a0000.gpu)

GPU_FREQ_PATH="/sys/class/devfreq/ff9a0000.gpu"

if [ -d "$GPU_FREQ_PATH" ]; then
    CUR=$(cat "$GPU_FREQ_PATH/cur_freq" 2>/dev/null || echo 0)
    MAX=$(cat "$GPU_FREQ_PATH/max_freq" 2>/dev/null || echo 800000000)
    GPU=$((CUR * 100 / MAX))

    # Get temperature from thermal zone (millicelsius)
    TEMPC=$(awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone1/temp 2>/dev/null)
else
    GPU=0
    TEMPC=0
fi

TEMPC=${TEMPC:-0}
TEMP=$((TEMPC * 9 / 5 + 32))

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

# Output JSON for waybar with pango markup (no wattage on ARM)
printf '{"text": "<span color=\\"#ffffff\\">GPU</span> <span color=\\"%s\\"> %3d%% %3d°</span>", "class": "%s"}\n' "$COLOR" "$GPU" "$TEMP" "$CLASS"
