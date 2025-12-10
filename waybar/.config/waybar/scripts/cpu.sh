#!/bin/bash
# CPU usage, temperature (Fahrenheit), and power consumption

CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)

# Get temperature: k10temp (AMD) or Core 0 (Intel)
TEMPC=$(sensors 2>/dev/null | awk '/^Tctl:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
if [ -z "$TEMPC" ]; then
    TEMPC=$(sensors 2>/dev/null | awk '/^Core 0:/ {gsub(/[^0-9.]/, "", $3); printf "%.0f", $3; exit}')
fi
TEMPC=${TEMPC:-0}
TEMP=$((TEMPC * 9 / 5 + 32))

# Get power consumption: battery sensor or RAPL
WATTS=$(sensors 2>/dev/null | awk '/^BAT0-acpi/,/^$/ {if (/^power1:/) {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2}}')
if [ -z "$WATTS" ] && [ -r /sys/class/powercap/intel-rapl:0/energy_uj ]; then
    E1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj)
    sleep 0.3
    E2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj)
    WATTS=$(( (E2 - E1) / 300000 ))
fi
WATTS=${WATTS:-0}

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
printf '{"text": "<span color=\\"#ffffff\\">CPU</span> <span color=\\"%s\\"> %3d%% %3d° %sW</span>", "class": "%s"}\n' "$COLOR" "$CPU" "$TEMP" "$WATTS" "$CLASS"
