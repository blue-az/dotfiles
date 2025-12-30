#!/bin/bash
# CPU usage, temperature (Fahrenheit), and power consumption

CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)

# Get temperature: k10temp (AMD) or Core 0 (Intel) or Package id (Intel fallback)
TEMPC=$(sensors 2>/dev/null | awk '/^Tctl:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
if [ -z "$TEMPC" ]; then
    TEMPC=$(sensors 2>/dev/null | awk '/^Core 0:/ {gsub(/\+|°C/, "", $3); printf "%.0f", $3; exit}')
fi
if [ -z "$TEMPC" ]; then
    TEMPC=$(sensors 2>/dev/null | awk '/^Package id 0:/ {gsub(/\+|°C/, "", $4); printf "%.0f", $4; exit}')
fi
TEMPC=${TEMPC:-0}
TEMP=$((TEMPC * 9 / 5 + 32))

# Get power consumption: battery sensor or RAPL (skip power if no data)
WATTS=$(sensors 2>/dev/null | awk '/^BAT0-acpi/,/^$/ {if (/^power1:/) {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2}}')
if [ -z "$WATTS" ] && [ -r /sys/class/powercap/intel-rapl:0/energy_uj ]; then
    E1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
    if [ -n "$E1" ]; then
        sleep 0.3
        E2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
        [ -n "$E2" ] && WATTS=$(( (E2 - E1) / 300000 ))
    fi
fi
WATTS=${WATTS:-}

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

# Output JSON for waybar (plain text, styling via CSS classes)
if [ -n "$WATTS" ]; then
    printf '{"text": "CPU %3d%% %3d° %sW", "class": "%s"}\n' "$CPU" "$TEMP" "$WATTS" "$CLASS"
else
    printf '{"text": "CPU %3d%% %3d°", "class": "%s"}\n' "$CPU" "$TEMP" "$CLASS"
fi
