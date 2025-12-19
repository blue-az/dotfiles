#!/bin/bash
# GPU usage, temperature (Fahrenheit), and power consumption

# Find AMD GPU sysfs path (could be card0 or card1)
GPU_PATH=$(ls -d /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
HAS_GPU=0

if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    # NVIDIA GPU
    HAS_GPU=1
    GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    TEMPC=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    WATTS=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits | awk '{printf "%.0f", $1}')
elif [ -n "$GPU_PATH" ]; then
    # AMD GPU with amdgpu driver (newer cards)
    HAS_GPU=1
    GPU=$(cat "$GPU_PATH" 2>/dev/null || echo 0)
    # Get temp from amdgpu edge sensor
    TEMPC=$(sensors 2>/dev/null | awk '/^edge:/ {gsub(/\+|°C/, "", $2); printf "%.0f", $2; exit}')
    # Get power from PPT sensor
    WATTS=$(sensors 2>/dev/null | awk '/^PPT:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
else
    # Check for older radeon driver with temp sensor
    TEMPC=$(sensors 2>/dev/null | awk '/^radeon-pci/,/^$/ {if (/^temp1:/ && !/N\/A/) {gsub(/\+|°C/, "", $2); printf "%.0f", $2; exit}}')
    if [ -n "$TEMPC" ] && [ "$TEMPC" != "0" ]; then
        HAS_GPU=1
        GPU=""
        WATTS=""
    fi
fi

GPU=${GPU:-}
TEMPC=${TEMPC:-}
WATTS=${WATTS:-}
[ -n "$TEMPC" ] && TEMP=$((TEMPC * 9 / 5 + 32)) || TEMP=""

# If no GPU data available, output empty (hides the module)
if [ "$HAS_GPU" -eq 0 ]; then
    printf '{"text": ""}\n'
    exit 0
fi

# Determine color based on temperature
TEMPC_NUM=${TEMPC:-0}
if [ "$TEMPC_NUM" -gt 80 ]; then
    COLOR="#ff5555"
    CLASS="critical"
elif [ "$TEMPC_NUM" -gt 65 ]; then
    COLOR="#f1fa8c"
    CLASS="warning"
else
    COLOR="#50fa7b"
    CLASS="normal"
fi

# Build output based on available data
if [ -n "$GPU" ] && [ -n "$TEMP" ] && [ -n "$WATTS" ]; then
    # Full data (NVIDIA or newer AMD)
    printf '{"text": "<span color=\\"#ffffff\\">GPU</span> <span color=\\"%s\\"> %3d%% %3d° %sW</span>", "class": "%s"}\n' "$COLOR" "$GPU" "$TEMP" "$WATTS" "$CLASS"
elif [ -n "$GPU" ] && [ -n "$TEMP" ]; then
    # Usage and temp only
    printf '{"text": "<span color=\\"#ffffff\\">GPU</span> <span color=\\"%s\\"> %3d%% %3d°</span>", "class": "%s"}\n' "$COLOR" "$GPU" "$TEMP" "$CLASS"
elif [ -n "$TEMP" ]; then
    # Temp only (older radeon with working temp sensor)
    printf '{"text": "<span color=\\"#ffffff\\">GPU</span> <span color=\\"%s\\"> %3d°</span>", "class": "%s"}\n' "$COLOR" "$TEMP" "$CLASS"
else
    # No useful data
    printf '{"text": ""}\n'
fi
