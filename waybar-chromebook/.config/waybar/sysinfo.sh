#!/bin/bash

# Get the focused workspace
SCREEN=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name' 2>/dev/null)
SCREEN=${SCREEN:-1}

# Disk
DISK=$(df -h / | awk 'NR==2 {print $4}')

# RAM
RAM=$(free -h | awk '/^Mem:/ {gsub("i","",$3); gsub("i","",$2); print $3 " / " $2}')

# CPU (Chromebook - thermal_zone0)
CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)
CPU_TEMPC=$(awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
CPU_TEMPC=${CPU_TEMPC:-0}
CPU_TEMP=$((CPU_TEMPC * 9 / 5 + 32))

# GPU (Mali via devfreq - frequency as percentage of max)
CUR_FREQ=$(cat /sys/class/devfreq/ff9a0000.gpu/cur_freq 2>/dev/null || echo 0)
MAX_FREQ=800000000
GPU=$((CUR_FREQ * 100 / MAX_FREQ))
GPU_TEMPC=$(awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone1/temp 2>/dev/null)
GPU_TEMPC=${GPU_TEMPC:-0}
GPU_TEMP=$((GPU_TEMPC * 9 / 5 + 32))

# IP (auto-detect first non-loopback)
IP=$(ip -4 addr show | grep -oP '(?<=inet\s)[\d.]+' | grep -v 127.0.0.1 | head -1)

# Battery (Chromebook uses sbs-9-000b)
BAT=""
if [ -d /sys/class/power_supply/sbs-9-000b ]; then
    CAP=$(cat /sys/class/power_supply/sbs-9-000b/capacity 2>/dev/null || echo 0)
    STATUS=$(cat /sys/class/power_supply/sbs-9-000b/status 2>/dev/null || echo "Unknown")
    BAT="${CAP}% (${STATUS})"
fi

# Date/time
DT=$(date '+%Y-%m-%d %I:%M:%S %p')

# Output with Pango markup matching conky style
TEXT="<span font_weight='bold' color='#50fa7b'>SYSTEM</span>
────────────────────
<span color='#50fa7b'>DISK</span>   ${DISK} free
<span color='#50fa7b'>RAM</span>    ${RAM}
<span color='#50fa7b'>CPU</span>    ${CPU}%  ${CPU_TEMP}°F
<span color='#50fa7b'>GPU</span>    ${GPU}%  ${GPU_TEMP}°F
<span color='#50fa7b'>IP</span>     ${IP}
<span color='#50fa7b'>BAT</span>    ${BAT}
────────────────────
       ${DT}
<span color='#50fa7b'>SCREEN</span> ${SCREEN}"

echo "{\"text\": \"$(echo "$TEXT" | sed ':a;N;$!ba;s/\n/\\n/g')\"}"
