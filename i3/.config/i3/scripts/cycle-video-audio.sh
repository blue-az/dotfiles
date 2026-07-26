#!/bin/bash
# Cycle through NVIDIA HDMI/DP audio outputs (pro-output-*)

# Nothing here may hardcode a PCI address or ALSA card index: both are assigned
# by the kernel and shifted when the RTX 2080 went in (GPU audio moved from
# pci-0000_01_00.1 to pci-0000_02_00.1, so the sink list came back empty and
# this script exited 1 without doing anything).

# Prefer monitor sink first when possible
preferred_monitor_patterns=(
    "XB271HU"
)

# ALSA card index of the GPU's HDMI audio - renumbers across GPU swaps
gpu_card=$(awk '/NVidia/ {gsub(/[^0-9]/, "", $1); print $1; exit}' /proc/asound/cards 2>/dev/null)

# The pro-audio profile is what exposes one sink per HDMI/DP output
# (pro-output-*). A GPU swap can reset the card to output:hdmi-stereo, which
# collapses all of them into a single sink and leaves nothing to cycle through.
ensure_pro_audio() {
    local card
    pactl list short sinks 2>/dev/null | grep -q 'pro-output-' && return 0
    card=$(pactl list cards 2>/dev/null | awk '
        /^Card #/ { name="" }
        /^[[:space:]]*Name:/ { name=$2 }
        /alsa\.card_name = "HDA NVidia"/ { if (name != "") { print name; exit } }
    ')
    [ -n "$card" ] || return 0
    pactl set-card-profile "$card" pro-audio 2>/dev/null || true
    sleep 1
}
ensure_pro_audio

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

    [ -n "$gpu_card" ] || return 1
    for eld_file in /proc/asound/card"$gpu_card"/eld#*; do
        [ -r "$eld_file" ] || continue
        if ! grep -q '^monitor_present[[:space:]]\+1' "$eld_file"; then
            continue
        fi
        if ! grep -q '^eld_valid[[:space:]]\+1' "$eld_file"; then
            continue
        fi
        # The field is separated from the key by *two* tabs, so -F'\t' '{print $2}'
        # returns an empty string and no monitor ever matched.
        name=$(awk '/^monitor_name/ {sub(/^monitor_name[[:space:]]+/, ""); print; exit}' "$eld_file")
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

# Get available NVIDIA HDMI/DP sinks (names), ordered by suffix
sinks=()
while IFS= read -r sink; do
    [ -n "$sink" ] && sinks+=("$sink")
done < <(pactl list sinks short 2>/dev/null | awk '{print $2}' | \
    grep -E '^alsa_output\..*\.pro-output-' | sort)

# Exit if no matches found
if [ ${#sinks[@]} -eq 0 ]; then
    exit 1
fi

preferred_sink=$(find_preferred_monitor_sink 2>/dev/null || true)
if [ -n "$preferred_sink" ] && printf '%s\n' "${sinks[@]}" | grep -qx "$preferred_sink"; then
    reordered=("$preferred_sink")
    for s in "${sinks[@]}"; do
        if [ "$s" != "$preferred_sink" ]; then
            reordered+=("$s")
        fi
    done
    sinks=("${reordered[@]}")
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
