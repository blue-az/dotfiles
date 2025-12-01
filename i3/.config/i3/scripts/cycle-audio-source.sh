#!/bin/bash
# Cycle through available audio sinks (outputs/speakers)

# Define sink patterns to cycle between (order matters)
# These match against node.nick or node.description from pw-cli
sink_patterns=(
    "EarPods"
    "Built-in Audio"
    "XB271HU"
)

# Get sink IDs matching our patterns
sinks=()
for pattern in "${sink_patterns[@]}"; do
    # Find Audio/Sink node ID by matching nick or description
    id=$(timeout 2 pw-cli list-objects Node 2>/dev/null | awk -v pat="$pattern" '
        /^[[:space:]]*id [0-9]+,/ { current_id = $2; gsub(",", "", current_id); is_sink = 0; matched = 0 }
        /media\.class = "Audio\/Sink"/ { is_sink = 1 }
        /node\.(nick|description) = / && index($0, pat) { matched = 1 }
        is_sink && matched { print current_id; exit }
    ')
    if [ -n "$id" ]; then
        sinks+=("$id")
    fi
done

# Exit if no sinks found
if [ ${#sinks[@]} -eq 0 ]; then
    exit 1
fi

# Get current default sink
current=$(timeout 2 wpctl status 2>/dev/null | sed -n '/Sinks:/,/Sources:/p' | grep '│.*\*' | grep -oP '^\s*│\s+\*\s*\K\d+(?=\.)')

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
timeout 2 wpctl set-default "$next_sink" 2>/dev/null || true
