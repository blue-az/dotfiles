#!/bin/bash
# Cycle the default audio output across displays that actually have one.
#
# Replaces the pro-output-N index cycling in cycle-audio-source.sh and
# cycle-video-audio.sh. Those iterate raw HDA channel pairs on whichever NVIDIA
# card sorts first -- which on this machine is the GPU with no displays plugged
# into it, so every entry in the cycle was a dead sink.
#
# The real work is in the sibling audio_cycle.py / audio_ports.py, which ask
# PipeWire which ports have a display present and label each by the EDID name
# the port reports. Nothing there keys on a sink index, a channel pair, an ALSA
# card number, or a PCI path: the kernel reassigns all of those.
#
# Those modules used to live in operator-control-plane and were reached through
# $OPERATOR_REPO. That coupling broke this binding twice -- once because the
# wrapper shipped before the Python existed, once because an operator reorg
# moved it into scripts/ -- so they now live here, next to their only caller.
set -uo pipefail

label=$(python3 "$(dirname "$(readlink -f "$0")")/audio_cycle.py" 2>/dev/null)

if [ -z "$label" ] || [ "$label" = "no live audio output" ]; then
    command -v notify-send >/dev/null && notify-send -t 2000 "Audio" "No live audio output"
    exit 1
fi

command -v notify-send >/dev/null && notify-send -t 1500 "Audio output" "$label"
echo "$label"
