#!/bin/bash
# Cycle through available audio sinks (outputs/speakers)

# Preferred order: monitor -> built-in -> earpods (if present)
builtin_sink="alsa_output.pci-0000_00_1f.3.analog-stereo"

preferred_monitor_patterns=(
    "XB271HU"
)

find_preferred_monitor_sink() {
    local pattern
    local eld_file
    local eld_index
    local sink
    local dev
    mapfile -t device_map < <(pactl list sinks 2>/dev/null | awk '
        /^Sink #/ { if (name != "") print name "|" dev; name=""; dev="" }
        /^Name:/ { name=$2 }
        /^[[:space:]]*alsa\.device =/ { gsub(/"/, "", $3); dev=$3 }
        END { if (name != "") print name "|" dev }
    ')

    for eld_file in /proc/asound/card1/eld#*; do
        [ -r "$eld_file" ] || continue
        if ! grep -q '^monitor_present[[:space:]]\+1' "$eld_file"; then
            continue
        fi
        if ! grep -q '^eld_valid[[:space:]]\+1' "$eld_file"; then
            continue
        fi
        name=$(awk -F '\t' '/^monitor_name/{print $2}' "$eld_file")
        for pattern in "${preferred_monitor_patterns[@]}"; do
            if echo "$name" | grep -qi "$pattern"; then
                eld_index="${eld_file##*.}"
                for entry in "${device_map[@]}"; do
                    sink="${entry%%|*}"
                    dev="${entry#*|}"
                    if [ "$dev" = "$eld_index" ]; then
                        echo "$sink"
                        return 0
                    fi
                done
            fi
        done
    done
    return 1
}

# Get available sinks (names)
all_sinks=$(pactl list sinks short 2>/dev/null | awk '{print $2}')
if [ -z "$all_sinks" ]; then
    exit 1
fi

find_by_desc() {
    local pattern="$1"
    pactl list sinks 2>/dev/null | awk -v pat="$pattern" '
        /^Name:/ { name=$2 }
        /^Description:/ {
            desc=$2
            for (i=3; i<=NF; i++) desc=desc" "$i
            if (tolower(desc) ~ tolower(pat)) { print name; exit }
        }
    '
}

sinks=()
monitor_sink=$(find_preferred_monitor_sink 2>/dev/null || true)
if [ -z "$monitor_sink" ]; then
    monitor_sink=$(echo "$all_sinks" | grep '^alsa_output\.pci-0000_01_00\.1\.pro-output-' | sort | head -1)
fi
if [ -n "$monitor_sink" ] && echo "$all_sinks" | grep -qx "$monitor_sink"; then
    sinks+=("$monitor_sink")
fi
if echo "$all_sinks" | grep -qx "$builtin_sink"; then
    sinks+=("$builtin_sink")
fi

earpods_sink=$(find_by_desc "EarPods")
if [ -n "$earpods_sink" ]; then
    sinks+=("$earpods_sink")
fi

if [ ${#sinks[@]} -eq 0 ]; then
    exit 1
fi

# Get current default sink
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
