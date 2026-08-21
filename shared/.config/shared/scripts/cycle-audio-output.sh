#!/bin/bash
# Cycle the default audio output across displays that actually have one.
#
# Replaces the pro-output-N index cycling in cycle-audio-source.sh and
# cycle-video-audio.sh. Those iterate raw HDA channel pairs on whichever NVIDIA
# card sorts first -- which on this machine is the GPU with no displays plugged
# into it, so every entry in the cycle was a dead sink.
#
# This asks PipeWire which ports have a display present, and labels each by the
# EDID name the port reports. Nothing here keys on a sink index, a channel pair,
# an ALSA card number, or a PCI path: the kernel reassigns all of those.
set -uo pipefail

REPO="${OPERATOR_REPO:-$HOME/operator-control-plane}"
label=$(python3 "$REPO/audio_cycle.py" 2>/dev/null)

if [ -z "$label" ] || [ "$label" = "no live audio output" ]; then
    command -v notify-send >/dev/null && notify-send -t 2000 "Audio" "No live audio output"
    exit 1
fi

command -v notify-send >/dev/null && notify-send -t 1500 "Audio output" "$label"
echo "$label"
