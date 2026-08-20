#!/bin/bash
# GPU usage, temperature (Fahrenheit), and power consumption

if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
     # NVIDIA GPU
     HAS_GPU=1
     
     # Get GPU Names
     NAME0=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader -i 0 | awk -F' ' '{print $4"-"$5}')
     NAME1=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader -i 1 2>/dev/null | awk -F' ' '{print $4"-"$5}')
     [ -z "$NAME1" ] && NAME1="None"

     # GPU 0
     GPU0=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader -i 0 | head -n 1 | sed 's/ %//' | awk '{printf "%2d", $1}')
     TEMPC0=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader -i 0 | head -n 1 | cut -d. -f1)
     WATTS0=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader -i 0 | head -n 1 | sed 's/ W//;s/W//' | awk '{printf "%5d", $1}')
     TEMP0=$((TEMPC0 * 9 / 5 + 32))
     
     # Determine Class for GPU 0
     CLASS0="normal"
     if [ "$WATTS0" -gt 350 ]; then CLASS0="critical"; elif [ "$WATTS0" -gt 50 ]; then CLASS0="warning"; fi

     # GPU 1
     GPU1=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader -i 1 2>/dev/null | head -n 1)
     if [ -n "$GPU1" ]; then
         GPU1=$(echo "$GPU1" | sed 's/ %//' | awk '{printf "%2d", $1}')
         TEMPC1=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader -i 1 2>/dev/null | head -n 1 | cut -d. -f1)
         WATTS1=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader -i 1 2>/dev/null | head -n 1 | sed 's/ W//;s/W//' | awk '{printf "%5d", $1}')
         TEMP1=$((TEMPC1 * 9 / 5 + 32))
         
         # Determine Class for GPU 1
         CLASS1="normal"
         if [ "$WATTS1" -gt 220 ]; then CLASS1="critical"; elif [ "$WATTS1" -gt 50 ]; then CLASS1="warning"; fi

         printf '{"text": "%s: %s%% %d° %sW | %s: %s%% %d° %sW", "class": "%s"}\n' \
             "$NAME0" "$GPU0" "$TEMP0" "$WATTS0" "$NAME1" "$GPU1" "$TEMP1" "$WATTS1" "$CLASS0"
     else
         printf '{"text": "%s: %s%% %d° %sW", "class": "%s"}\n' "$NAME0" "$GPU0" "$TEMP0" "$WATTS0" "$CLASS0"
     fi
     
     exit 0







    exit 0
fi

# AMD/Other Fallback
GPU_PATH=$(ls -d /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
if [ -n "$GPU_PATH" ]; then
    HAS_GPU=1
    GPU=$(cat "$GPU_PATH" 2>/dev/null || echo 0)
    TEMPC=$(sensors 2>/dev/null | awk '/^edge:/ {gsub(/\+|°C/, "", $2); printf "%.0f", $2; exit}')
    WATTS=$(sensors 2>/dev/null | awk '/^PPT:/ {gsub(/[^0-9.]/, "", $2); printf "%.0f", $2; exit}')
    TEMP=$((TEMPC * 9 / 5 + 32))
    printf '{"text": "GPU %s%% %d° %sW", "class": "normal"}\n' "$GPU" "$TEMP" "$WATTS"
else
    printf '{"text": ""}\n'
fi
