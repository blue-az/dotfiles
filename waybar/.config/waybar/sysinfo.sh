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

# The overlay is the headless monitor: read both testbench cards, not this desktop GPU.
TESTBENCH_GPU_LINES=""
CARD_INDEX=0
while IFS=',' read -r NAME UTIL TEMP WATTS LIMIT USED TOTAL; do
    NAME=$(printf '%s' "$NAME" | sed 's/^ *//;s/ *$//')
    UTIL=$(printf '%s' "$UTIL" | sed 's/^ *//;s/ *$//')
    TEMP=$(printf '%s' "$TEMP" | sed 's/^ *//;s/ *$//')
    WATTS=$(printf '%s' "$WATTS" | sed 's/^ *//;s/ *$//')
    LIMIT=$(printf '%s' "$LIMIT" | sed 's/^ *//;s/ *$//')
    USED=$(printf '%s' "$USED" | sed 's/^ *//;s/ *$//')
    TOTAL=$(printf '%s' "$TOTAL" | sed 's/^ *//;s/ *$//')
    [ -n "$NAME" ] || continue
    # nvidia-smi output is numeric after the fixed label; keep the overlay safe
    # if a remote command returns unexpected text.
    case "$UTIL$TEMP$WATTS$LIMIT$USED$TOTAL" in
        *[!0-9.]*) continue ;;
    esac
    VENDOR="ZOTAC"
    [ "$CARD_INDEX" -eq 0 ] && VENDOR="EVGA"
    MODEL=$(printf '%s' "$NAME" | sed 's/^NVIDIA GeForce RTX /RTX /')
    printf -v VENDOR_PAD '%-5s' "$VENDOR"
    TESTBENCH_GPU_LINES="${TESTBENCH_GPU_LINES}<span color='#50fa7b'>${VENDOR_PAD}</span> ${MODEL} ${UTIL}%  ${TEMP}°C  ${WATTS}W (${USED}/${TOTAL}MiB)\n"
    CARD_INDEX=$((CARD_INDEX + 1))
done < <(timeout 2 ssh -o BatchMode=yes -o ConnectTimeout=1 -o ConnectionAttempts=1 testbench \
    'nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,power.draw,power.limit,memory.used,memory.total --format=csv,noheader,nounits' 2>/dev/null || true)
[ -n "$TESTBENCH_GPU_LINES" ] || TESTBENCH_GPU_LINES="<span color='#50fa7b'>TB GPU</span>  unavailable\n"

# IP (auto-detect first non-loopback)
if [ -f ~/.config/privacy-mode ]; then
    IP="***.***.***.***"
else
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)[\d.]+' | grep -v 127.0.0.1 | head -1)
fi

# Date/time
DT=$(date '+%Y-%m-%d %I:%M:%S %p')

# Build CPU and GPU lines based on available data
CPU_LINE="<span color='#50fa7b'>CPU</span>    ${CPU}%  ${CPU_TEMP}°F"
[ -n "$CPU_W" ] && CPU_LINE="${CPU_LINE}  ${CPU_W}W"

GPU_LINE="$TESTBENCH_GPU_LINES"

# Output with Pango markup matching conky style
TEXT="<span font_weight='bold' color='#50fa7b'>HEADLESS MONITOR</span>
────────────────────
<span color='#50fa7b'>DISK</span>   ${DISK} free
<span color='#50fa7b'>RAM</span>    ${RAM}
${CPU_LINE}
${GPU_LINE}<span color='#50fa7b'>IP</span>     ${IP}
────────────────────
       ${DT}
<span color='#50fa7b'>SCREEN</span> ${SCREEN}"

echo "{\"text\": \"$(echo "$TEXT" | sed ':a;N;$!ba;s/\n/\\n/g')\"}"
