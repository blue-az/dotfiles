#!/bin/bash
# Cycle through HDMI audio outputs using stable ALSA device names

# Define sinks by stable ALSA name patterns (PCI path based, won't change)
# These are substrings that match the pactl sink names
sink_patterns=(
    "pro-output-3"   # HDMI 0 - LG TV
    "pro-output-8"   # HDMI 2 - LG TV
    "pro-output-9"   # HDMI 3 - spare
)

# Get available sinks matching our patterns
sinks=()
all_sinks=$(pactl list sinks short 2>/dev/null | awk '{print $2}')
for pattern in "${sink_patterns[@]}"; do
    match=$(echo "$all_sinks" | grep "$pattern" | head -1)
    if [ -n "$match" ]; then
        sinks+=("$match")
    fi
done

# Exit if no sinks found
if [ ${#sinks[@]} -eq 0 ]; then
    exit 1
fi

# Get current default sink name
current=$(pactl get-default-sink 2>/dev/null)

# Find current index
current_index=-1
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current" ]]; then
        current_index=$i
        break
    fi
done

# Calculate next index (cycle back to 0 if at end)
if [ $current_index -eq -1 ]; then
    next_index=0
else
    next_index=$(( (current_index + 1) % ${#sinks[@]} ))
fi
next_sink="${sinks[$next_index]}"

# Set the new default sink
pactl set-default-sink "$next_sink" 2>/dev/null || true
