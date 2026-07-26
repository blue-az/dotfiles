#!/bin/bash
# Cycle through available audio sinks (outputs/speakers)

# Nothing here may hardcode a PCI address or ALSA card index: both are assigned
# by the kernel and shifted when the RTX 2080 went in (GPU audio moved from
# pci-0000_01_00.1 to pci-0000_02_00.1, so the sink grep matched nothing and
# this script silently collapsed to a one-item cycle).

# Preferred order: monitor -> built-in -> earpods (if present)
builtin_sink="alsa_output.pci-0000_00_1f.3.analog-stereo"

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

# Map monitors to sinks by rank: the Nth ELD reporting a monitor (in pin order)
# is the Nth pro-output sink (in device order). Matching the ELD index directly
# against alsa.device cannot work - the pin indices (0, 4) and the sink device
# numbers (3, 7, 8, 9) are separate numbering schemes, so the preferred monitor
# never resolved and the cycle fell back to whichever sink sorted first.
find_preferred_monitor_sink() {
    local pattern
    local eld_file
    local name
    local rank=0
    local -a live_sinks
    local -a eld_files

    [ -n "$gpu_card" ] || return 1

    mapfile -t live_sinks < <(pactl list short sinks 2>/dev/null | awk '{print $2}' |
        grep -E '^alsa_output\..*\.pro-output-' |
        awk -F'pro-output-' '{print $2"\t"$0}' | sort -n -k1,1 | cut -f2)
    [ "${#live_sinks[@]}" -gt 0 ] || return 1

    mapfile -t eld_files < <(for eld_file in /proc/asound/card"$gpu_card"/eld#*; do
        [ -r "$eld_file" ] && printf '%s\t%s\n' "${eld_file##*.}" "$eld_file"
    done | sort -n -k1,1 | cut -f2)

    for eld_file in "${eld_files[@]}"; do
        grep -q '^monitor_present[[:space:]]\+1' "$eld_file" || continue
        grep -q '^eld_valid[[:space:]]\+1' "$eld_file" || continue
        # The value is separated from its key by *two* tabs, so the previous
        # -F'\t' '{print $2}' returned an empty string and never matched.
        name=$(awk '/^monitor_name/ {sub(/^monitor_name[[:space:]]+/, ""); print; exit}' "$eld_file")
        for pattern in "${preferred_monitor_patterns[@]}"; do
            if echo "$name" | grep -qi "$pattern"; then
                if [ "$rank" -lt "${#live_sinks[@]}" ]; then
                    echo "${live_sinks[$rank]}"
                    return 0
                fi
            fi
        done
        rank=$((rank + 1))
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
    monitor_sink=$(echo "$all_sinks" | grep -E '^alsa_output\..*\.pro-output-' | sort | head -1)
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
