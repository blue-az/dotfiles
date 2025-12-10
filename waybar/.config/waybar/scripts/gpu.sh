#!/bin/bash
# GPU usage, temperature (Fahrenheit), and power consumption

# Find AMD GPU sysfs path (could be card0 or card1)
GPU_PATH=$(ls -d /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)

if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    # NVIDIA GPU
    GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    TEMPC=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    WATTS=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits | awk '{printf "%.0f", $1}')
elif [ -n "$GPU_PATH" ]; then
    # AMD GPU
    GPU=$(cat "$GPU_PATH" 2>/dev/null || echo 0)
    # Get temp from amdgpu edge sensor
    TEMPC=$(sensors 2>/dev/null | awk '/^edge:/ {gsub(/\+|°C/, "", $2); printf "%.0f", $2; exit}')
    # Get power from PPT sensor
    WATTS=$(sensors 2>/dev/null | awk '/^PPT:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
else
    GPU=0
    TEMPC=0
    WATTS=0
fi

GPU=${GPU:-0}
TEMPC=${TEMPC:-0}
WATTS=${WATTS:-0}
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

# Output JSON for waybar with pango markup
printf '{"text": "<span color=\\"#ffffff\\">GPU</span> <span color=\\"%s\\"> %3d%% %3d° %sW</span>", "class": "%s"}\n' "$COLOR" "$GPU" "$TEMP" "$WATTS" "$CLASS"
