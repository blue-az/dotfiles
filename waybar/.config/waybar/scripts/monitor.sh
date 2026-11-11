#!/bin/bash
# Live CPU and GPU percentage monitor

# CPU usage
CPU=$(awk '/^cpu / {printf "%.0f", ($2+$4)*100/($2+$4+$5)}' /proc/stat)

# Headless testbench GPU usage: keep both cards independent.
mapfile -t TESTBENCH_GPUS < <(timeout 2 ssh -o BatchMode=yes -o ConnectTimeout=1 \
    -o ConnectionAttempts=1 testbench \
    'nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits' 2>/dev/null || true)
# Empty means no reading (testbench unreachable or bad output), never 0%.
GPU0=$(printf '%s' "${TESTBENCH_GPUS[0]:-}" | tr -cd '0-9')
GPU1=$(printf '%s' "${TESTBENCH_GPUS[1]:-}" | tr -cd '0-9')

# Color thresholds
cpu_class="normal"
[ "$CPU" -gt 50 ] && cpu_class="warning"
[ "$CPU" -gt 80 ] && cpu_class="critical"

gpu_class="normal"
[ "${GPU0:-0}" -gt 50 ] || [ "${GPU1:-0}" -gt 50 ] && gpu_class="warning"
[ "${GPU0:-0}" -gt 80 ] || [ "${GPU1:-0}" -gt 80 ] && gpu_class="critical"

# Build visual bar (20 chars wide) using ASCII
bar() {
    local pct=$1 width=20
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    printf '%*s' "$filled" '' | tr ' ' '#'
    printf '%*s' "$empty" '' | tr ' ' '-'
}

# "NNN% [bar]", or " n/a [    ]" when the card has no reading.
gpu_field() {
    if [ -n "$1" ]; then
        printf '%3d%% [%s]' "$1" "$(bar "$1")"
    else
        printf ' n/a [%20s]' ''
    fi
}

CPU_BAR=$(bar "$CPU")

TEXT="CPU $(printf '%3d' "$CPU")% [${CPU_BAR}]  EVGA $(gpu_field "$GPU0")  ZOTAC $(gpu_field "$GPU1")"

# Determine overall class (worst of the two)
CLASS="normal"
[ "$cpu_class" = "warning" ] || [ "$gpu_class" = "warning" ] && CLASS="warning"
[ "$cpu_class" = "critical" ] || [ "$gpu_class" = "critical" ] && CLASS="critical"

printf '{"text": "%s", "class": "%s"}\n' "$TEXT" "$CLASS"
