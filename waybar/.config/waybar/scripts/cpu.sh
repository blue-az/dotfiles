#!/bin/bash
# CPU usage, temperature (Fahrenheit), and power consumption

# CPU usage: /proc/stat counters are cumulative since boot, so a single
# sample reports the since-boot average (which barely moves under load).
# Cache the previous sample and report the delta between the two.
CPU_CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-cpu.prev"
read -r _ C_USER C_NICE C_SYS C_IDLE C_IOWAIT C_IRQ C_SIRQ C_STEAL _ < /proc/stat
IDLE_NOW=$((C_IDLE + C_IOWAIT))
TOTAL_NOW=$((C_USER + C_NICE + C_SYS + C_IDLE + C_IOWAIT + C_IRQ + C_SIRQ + C_STEAL))

TOTAL_PREV=0
IDLE_PREV=0
[ -r "$CPU_CACHE" ] && read -r TOTAL_PREV IDLE_PREV < "$CPU_CACHE"
case "$TOTAL_PREV$IDLE_PREV" in
    '' | *[!0-9]*) TOTAL_PREV=0; IDLE_PREV=0 ;;
esac
printf '%s %s\n' "$TOTAL_NOW" "$IDLE_NOW" > "$CPU_CACHE"

D_TOTAL=$((TOTAL_NOW - TOTAL_PREV))
D_IDLE=$((IDLE_NOW - IDLE_PREV))
if [ "$D_TOTAL" -gt 0 ] && [ "$D_IDLE" -ge 0 ]; then
    CPU=$(( (100 * (D_TOTAL - D_IDLE) + D_TOTAL / 2) / D_TOTAL ))
else
    CPU=0
fi
[ "$CPU" -lt 0 ] && CPU=0
[ "$CPU" -gt 100 ] && CPU=100

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
    CLASS="critical"
elif [ $TEMPC -gt 65 ]; then
    CLASS="warning"
else
    CLASS="normal"
fi

# Output JSON for waybar (plain text, styling via CSS classes)
if [ -n "$WATTS" ]; then
    printf '{"text": "CPU %3d%% %3d° %3sW", "class": "%s"}\n' "$CPU" "$TEMP" "$WATTS" "$CLASS"
else
    printf '{"text": "CPU %3d%% %3d°", "class": "%s"}\n' "$CPU" "$TEMP" "$CLASS"
fi
