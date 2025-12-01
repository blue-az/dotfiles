#!/bin/bash

# Get workspace
WS=$(swaymsg -t get_workspaces 2>/dev/null | jq -r '.[] | select(.focused) | .name')

# Disk
DISK=$(df -h / | awk 'NR==2 {print $4}')

# RAM
RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')

# CPU
CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)
CPU_TEMP=$(sensors 2>/dev/null | awk '/^Core 0:/ {gsub(/[^0-9.]/, "", $3); printf "%.0f", $3 * 9/5 + 32}')

# CPU Power
E1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
sleep 0.3
E2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
CPU_W=$(( (E2 - E1) / 300000 ))

# GPU
GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | awk '{printf "%.0f", $1 * 9/5 + 32}')
GPU_W=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | awk '{printf "%.0f", $1}')

# IP
IP=$(ip -4 addr show eno1 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)

# Output with Pango markup for colors
echo "<span color='#50fa7b'>SYSTEM</span>
<span color='#50fa7b'>DISK</span>    ${DISK} free
<span color='#50fa7b'>RAM</span>     ${RAM}
<span color='#50fa7b'>CPU</span>     ${CPU}%  ${CPU_TEMP}°F
<span color='#50fa7b'>CPU-W</span>   ${CPU_W}W
<span color='#50fa7b'>GPU</span>     ${GPU}%  ${GPU_TEMP}°F
<span color='#50fa7b'>GPU-W</span>   ${GPU_W}W
<span color='#50fa7b'>IP</span>      ${IP}
──────────────────
<span color='#51a2da'>WORKSPACE ${WS}</span>"
