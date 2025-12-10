#!/bin/bash
# Audio volume with device name

SINK=$(pactl get-default-sink 2>/dev/null)
VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+%' | head -1 | tr -d '%')
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -oP '(yes|no)')

case "$SINK" in
    *EarPods*) NAME="EarPods";;
    *analog-stereo*) NAME="Built-in";;
    *pro-output-3*) NAME="LG";;
    *pro-output-7*) NAME="Monitor";;
    *pro-output-8*) NAME="HDMI-2";;
    *pro-output-9*) NAME="HDMI-3";;
    *) NAME="Unknown";;
esac

if [ "$MUTE" = "yes" ]; then
    echo '{"text": "<span color=\"#ffffff\">VOL</span> <span color=\"#ff5555\"> MUTE '"$NAME"'</span>", "class": "muted"}'
elif [ "$VOL" -gt 100 ]; then
    echo '{"text": "<span color=\"#ffffff\">VOL</span> <span color=\"#f1fa8c\"> '"$VOL"'% '"$NAME"'</span>", "class": "warning"}'
else
    echo '{"text": "<span color=\"#ffffff\">VOL</span> <span color=\"#50fa7b\"> '"$VOL"'% '"$NAME"'</span>", "class": "normal"}'
fi
