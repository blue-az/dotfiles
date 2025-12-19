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

# CPU temp: Intel (Core 0) or AMD (Tctl) or Package id fallback
CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)
CPU_TEMPC=$(sensors 2>/dev/null | awk '/^Tctl:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
if [ -z "$CPU_TEMPC" ]; then
    CPU_TEMPC=$(sensors 2>/dev/null | awk '/^Core 0:/ {gsub(/\+|°C/, "", $3); printf "%.0f", $3; exit}')
fi
if [ -z "$CPU_TEMPC" ]; then
    CPU_TEMPC=$(sensors 2>/dev/null | awk '/^Package id 0:/ {gsub(/\+|°C/, "", $4); printf "%.0f", $4; exit}')
fi
CPU_TEMPC=${CPU_TEMPC:-0}
CPU_TEMP=$((CPU_TEMPC * 9 / 5 + 32))

# CPU Power: Intel RAPL or BAT0 power sensor
CPU_W=""
if [ -r /sys/class/powercap/intel-rapl:0/energy_uj ]; then
    E1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
    if [ -n "$E1" ]; then
        sleep 0.3
        E2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
        [ -n "$E2" ] && CPU_W=$(( (E2 - E1) / 300000 ))
    fi
fi
if [ -z "$CPU_W" ]; then
    CPU_W=$(sensors 2>/dev/null | awk '/^BAT0-acpi/,/^$/ {if (/^power1:/) {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2}}')
fi

# GPU: NVIDIA (nvidia-smi) or AMD (sysfs/sensors)
GPU_PATH=$(ls -d /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
HAS_GPU=0
if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    HAS_GPU=1
    GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
    GPU_TEMPC=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    GPU_W=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | awk '{printf "%.0f", $1}')
elif [ -n "$GPU_PATH" ]; then
    HAS_GPU=1
    GPU=$(cat "$GPU_PATH" 2>/dev/null || echo 0)
    GPU_TEMPC=$(sensors 2>/dev/null | awk '/^edge:/ {gsub(/\+|°C/, "", $2); printf "%.0f", $2; exit}')
    GPU_W=$(sensors 2>/dev/null | awk '/^PPT:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
else
    # Check for older radeon driver with temp sensor
    GPU_TEMPC=$(sensors 2>/dev/null | awk '/^radeon-pci/,/^$/ {if (/^temp1:/ && !/N\/A/) {gsub(/\+|°C/, "", $2); printf "%.0f", $2; exit}}')
    if [ -n "$GPU_TEMPC" ] && [ "$GPU_TEMPC" != "0" ]; then
        HAS_GPU=1
        GPU=""
        GPU_W=""
    fi
fi
GPU=${GPU:-}
GPU_TEMPC=${GPU_TEMPC:-}
[ -n "$GPU_TEMPC" ] && GPU_TEMP=$((GPU_TEMPC * 9 / 5 + 32)) || GPU_TEMP=""
GPU_W=${GPU_W:-}

# IP (auto-detect first non-loopback)
IP=$(ip -4 addr show | grep -oP '(?<=inet\s)[\d.]+' | grep -v 127.0.0.1 | head -1)

# Date/time
DT=$(date '+%Y-%m-%d %I:%M:%S %p')

# Build CPU and GPU lines based on available data
CPU_LINE="<span color='#50fa7b'>CPU</span>    ${CPU}%  ${CPU_TEMP}°F"
[ -n "$CPU_W" ] && CPU_LINE="${CPU_LINE}  ${CPU_W}W"

if [ "$HAS_GPU" -eq 1 ]; then
    GPU_LINE="<span color='#50fa7b'>GPU</span>   "
    [ -n "$GPU" ] && GPU_LINE="${GPU_LINE} ${GPU}%"
    [ -n "$GPU_TEMP" ] && GPU_LINE="${GPU_LINE}  ${GPU_TEMP}°F"
    [ -n "$GPU_W" ] && GPU_LINE="${GPU_LINE}  ${GPU_W}W"
    GPU_LINE="${GPU_LINE}
"
else
    GPU_LINE=""
fi

# Output with Pango markup matching conky style
TEXT="<span font_weight='bold' color='#50fa7b'>SYSTEM</span>
────────────────────
<span color='#50fa7b'>DISK</span>   ${DISK} free
<span color='#50fa7b'>RAM</span>    ${RAM}
${CPU_LINE}
${GPU_LINE}<span color='#50fa7b'>IP</span>     ${IP}
────────────────────
       ${DT}
<span color='#50fa7b'>SCREEN</span> ${SCREEN}"

echo "{\"text\": \"$(echo "$TEXT" | sed ':a;N;$!ba;s/\n/\\n/g')\"}"
