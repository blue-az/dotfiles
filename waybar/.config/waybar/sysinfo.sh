#!/bin/bash

# Get output name where this waybar instance is displayed
OUTPUT=${WAYBAR_OUTPUT_NAME:-unknown}

# Get the focused workspace on this output
SCREEN=$(swaymsg -t get_workspaces | jq -r --arg out "$OUTPUT" '.[] | select(.output == $out and .focused) | .name' | head -1)
# Fallback to visible workspace on this output if none focused
if [ -z "$SCREEN" ]; then
    SCREEN=$(swaymsg -t get_workspaces | jq -r --arg out "$OUTPUT" '.[] | select(.output == $out and .visible) | .name' | head -1)
fi
SCREEN=${SCREEN:-$OUTPUT}

# Disk
DISK=$(df -h / | awk 'NR==2 {print $4}')

# RAM
RAM=$(free -h | awk '/^Mem:/ {gsub("i","",$3); gsub("i","",$2); print $3 " / " $2}')

# CPU temp: Intel (Core 0) or AMD (temp1 from acpitz)
CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)
CPU_TEMPC=$(sensors 2>/dev/null | awk '/^Core 0:/ {gsub(/[^0-9.]/, "", $3); printf "%.0f", $3; exit}')
if [ -z "$CPU_TEMPC" ]; then
    CPU_TEMPC=$(sensors 2>/dev/null | awk '/^temp1:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
fi
CPU_TEMPC=${CPU_TEMPC:-0}
CPU_TEMP=$((CPU_TEMPC * 9 / 5 + 32))

# CPU Power: Intel RAPL or BAT0 power sensor
if [ -r /sys/class/powercap/intel-rapl:0/energy_uj ]; then
    E1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj)
    sleep 0.3
    E2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj)
    CPU_W=$(( (E2 - E1) / 300000 ))
else
    CPU_W=$(sensors 2>/dev/null | awk '/^power1:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
fi
CPU_W=${CPU_W:-0}

# GPU: NVIDIA (nvidia-smi) or AMD (sysfs/sensors)
if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
    GPU_TEMPC=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    GPU_W=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | awk '{printf "%.0f", $1}')
else
    GPU=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo 0)
    GPU_TEMPC=$(sensors 2>/dev/null | awk '/^edge:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2}')
    GPU_W=$(sensors 2>/dev/null | awk '/^PPT:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2}')
fi
GPU=${GPU:-0}
GPU_TEMPC=${GPU_TEMPC:-0}
GPU_TEMP=$((GPU_TEMPC * 9 / 5 + 32))
GPU_W=${GPU_W:-0}

# IP (auto-detect first non-loopback)
IP=$(ip -4 addr show | grep -oP '(?<=inet\s)[\d.]+' | grep -v 127.0.0.1 | head -1)

# Date/time
DT=$(date '+%Y-%m-%d %I:%M:%S %p')

# Output with Pango markup matching conky style
TEXT="<span font_weight='bold' color='#50fa7b'>SYSTEM</span>
────────────────────
<span color='#50fa7b'>DISK</span>   ${DISK} free
<span color='#50fa7b'>RAM</span>    ${RAM}
<span color='#50fa7b'>CPU</span>    ${CPU}%  ${CPU_TEMP}°F  ${CPU_W}W
<span color='#50fa7b'>GPU</span>    ${GPU}%  ${GPU_TEMP}°F  ${GPU_W}W
<span color='#50fa7b'>IP</span>     ${IP}
────────────────────
       ${DT}
<span color='#50fa7b'>SCREEN</span> ${SCREEN}"

echo "{\"text\": \"$(echo "$TEXT" | sed ':a;N;$!ba;s/\n/\\n/g')\"}"
