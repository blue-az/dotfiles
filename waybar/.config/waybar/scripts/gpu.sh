#!/bin/bash
# GPU usage, temperature (Fahrenheit), and power consumption

# waybar takes a single class per module, so a multi-GPU box reports the
# worst class across all of its cards.
worse_class() {
    case "$1$2" in
        *critical*) echo critical ;;
        *warning*)  echo warning  ;;
        *)          echo normal   ;;
    esac
}

# Strip units/junk and round; falls back to $2 when the field is [N/A].
num() {
    local v=${1//[!0-9.]/}
    [ -z "$v" ] && { echo "${2:-0}"; return; }
    printf '%.0f' "$v" 2>/dev/null || echo "${2:-0}"
}

if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    # One query for every GPU rather than four per card.
    mapfile -t ROWS < <(nvidia-smi \
        --query-gpu=gpu_name,utilization.gpu,temperature.gpu,power.draw,power.limit \
        --format=csv,noheader,nounits 2>/dev/null)

    TEXT=""
    CLASS="normal"
    for ROW in "${ROWS[@]}"; do
        IFS=',' read -r NAME UTIL TEMPC WATTS LIMIT <<< "$ROW"

        # "NVIDIA GeForce RTX 3090" -> "3090"; "... RTX 4070 Ti" -> "4070-Ti"
        NAME=$(awk '{sub(/^ +/, ""); sub(/^NVIDIA +/, ""); sub(/^GeForce +/, "");
                     sub(/^(RTX|GTX|GT) +/, ""); gsub(/ +/, "-"); print}' <<< "$NAME")
        [ -z "$NAME" ] && NAME="GPU"

        UTIL=$(num "$UTIL" 0)
        TEMPC=$(num "$TEMPC" 0)
        WATTS=$(num "$WATTS" 0)
        LIMIT=$(num "$LIMIT" 0)
        TEMPF=$((TEMPC * 9 / 5 + 32))

        # Critical at 90% of the card's own enforced cap, so the threshold
        # tracks the hardware instead of a hardcoded number that may sit
        # above what the card is even allowed to draw.
        GCLASS="normal"
        if [ "$LIMIT" -gt 0 ] && [ "$WATTS" -gt $((LIMIT * 9 / 10)) ]; then
            GCLASS="critical"
        elif [ "$WATTS" -gt 50 ]; then
            GCLASS="warning"
        fi
        CLASS=$(worse_class "$CLASS" "$GCLASS")

        [ -n "$TEXT" ] && TEXT+=" | "
        TEXT+=$(printf '%s: %2d%% %3d° %3dW' "$NAME" "$UTIL" "$TEMPF" "$WATTS")
    done

    if [ -n "$TEXT" ]; then
        printf '{"text": "%s", "class": "%s"}\n' "$TEXT" "$CLASS"
        exit 0
    fi
fi

# AMD/Other Fallback
GPU_PATH=$(ls -d /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
if [ -n "$GPU_PATH" ]; then
    GPU=$(num "$(cat "$GPU_PATH" 2>/dev/null)" 0)
    TEMPC=$(sensors 2>/dev/null | awk '/^edge:/ {gsub(/\+|°C/, "", $2); printf "%.0f", $2; exit}')
    WATTS=$(sensors 2>/dev/null | awk '/^PPT:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
    TEMPC=${TEMPC:-0}
    TEMP=$((TEMPC * 9 / 5 + 32))

    # No reliable power cap to read here, so colour by temperature the way
    # cpu.sh does instead of inventing a wattage threshold.
    CLASS="normal"
    if [ "$TEMPC" -gt 80 ]; then
        CLASS="critical"
    elif [ "$TEMPC" -gt 65 ]; then
        CLASS="warning"
    fi

    if [ -n "$WATTS" ]; then
        printf '{"text": "GPU %2d%% %3d° %3dW", "class": "%s"}\n' "$GPU" "$TEMP" "$WATTS" "$CLASS"
    else
        printf '{"text": "GPU %2d%% %3d°", "class": "%s"}\n' "$GPU" "$TEMP" "$CLASS"
    fi
else
    printf '{"text": ""}\n'
fi
