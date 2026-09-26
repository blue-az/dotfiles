#!/bin/bash
# Live CPU and GPU percentage monitor

# CPU usage
CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)

# Headless testbench GPU usage: keep both cards independent.
mapfile -t TESTBENCH_GPUS < <(timeout 2 ssh -o BatchMode=yes -o ConnectTimeout=1 \
    -o ConnectionAttempts=1 testbench \
    'nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits' 2>/dev/null || true)
GPU0=$(printf '%s' "${TESTBENCH_GPUS[0]:-0}" | tr -cd '0-9')
GPU1=$(printf '%s' "${TESTBENCH_GPUS[1]:-0}" | tr -cd '0-9')
GPU0=${GPU0:-0}
GPU1=${GPU1:-0}

# Color thresholds
cpu_class="normal"
[ "$CPU" -gt 50 ] && cpu_class="warning"
[ "$CPU" -gt 80 ] && cpu_class="critical"

gpu_class="normal"
[ "$GPU0" -gt 50 ] || [ "$GPU1" -gt 50 ] && gpu_class="warning"
[ "$GPU0" -gt 80 ] || [ "$GPU1" -gt 80 ] && gpu_class="critical"

# Build visual bar (20 chars wide) using ASCII
bar() {
    local pct=$1 width=20
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    printf '%*s' "$filled" '' | tr ' ' '#'
    printf '%*s' "$empty" '' | tr ' ' '-'
}

CPU_BAR=$(bar "$CPU")
GPU0_BAR=$(bar "$GPU0")
GPU1_BAR=$(bar "$GPU1")

TEXT="CPU $(printf '%3d' "$CPU")% [$(bar "$CPU")]  EVGA $(printf '%3d' "$GPU0")% [${GPU0_BAR}]  ZOTAC $(printf '%3d' "$GPU1")% [${GPU1_BAR}]"

# Determine overall class (worst of the two)
CLASS="normal"
[ "$cpu_class" = "warning" ] || [ "$gpu_class" = "warning" ] && CLASS="warning"
[ "$cpu_class" = "critical" ] || [ "$gpu_class" = "critical" ] && CLASS="critical"

printf '{"text": "%s", "class": "%s"}\n' "$TEXT" "$CLASS"
