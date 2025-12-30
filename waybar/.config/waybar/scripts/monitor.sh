#!/bin/bash
# Live CPU and GPU percentage monitor

# CPU usage
CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)

# GPU usage (NVIDIA or AMD)
GPU=""
if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
else
    GPU_PATH=$(ls -d /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
    [ -n "$GPU_PATH" ] && GPU=$(cat "$GPU_PATH" 2>/dev/null)
fi
GPU=${GPU:-0}

# Color thresholds
cpu_class="normal"
[ "$CPU" -gt 50 ] && cpu_class="warning"
[ "$CPU" -gt 80 ] && cpu_class="critical"

gpu_class="normal"
[ "$GPU" -gt 50 ] && gpu_class="warning"
[ "$GPU" -gt 80 ] && gpu_class="critical"

# Build visual bar (20 chars wide) using ASCII
bar() {
    local pct=$1 width=20
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    printf '%*s' "$filled" '' | tr ' ' '#'
    printf '%*s' "$empty" '' | tr ' ' '-'
}

CPU_BAR=$(bar "$CPU")
GPU_BAR=$(bar "$GPU")

TEXT="CPU $(printf '%3d' "$CPU")% [${CPU_BAR}]  GPU $(printf '%3d' "$GPU")% [${GPU_BAR}]"

# Determine overall class (worst of the two)
CLASS="normal"
[ "$cpu_class" = "warning" ] || [ "$gpu_class" = "warning" ] && CLASS="warning"
[ "$cpu_class" = "critical" ] || [ "$gpu_class" = "critical" ] && CLASS="critical"

printf '{"text": "%s", "class": "%s"}\n' "$TEXT" "$CLASS"
