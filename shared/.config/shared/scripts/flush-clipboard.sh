#!/bin/bash

set -u

target="${1:-all}"

case "$target" in
    all)
        wl-copy --clear
        wl-copy --primary --clear
        message="Cleared clipboard and primary selection"
        ;;
    clip|clipboard)
        wl-copy --clear
        message="Cleared clipboard"
        ;;
    prim|primary)
        wl-copy --primary --clear
        message="Cleared primary selection"
        ;;
    *)
        message="Unknown clipboard target: $target"
        notify-send "Clipboard" "$message"
        exit 1
        ;;
esac

notify-send "Clipboard" "$message"
