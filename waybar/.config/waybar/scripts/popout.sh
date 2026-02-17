#!/bin/bash
# Popout helper for waybar module clicks
set -euo pipefail

ACTION=${1:-}

open_term() {
    local cmd="$*"
    local term=""

    for t in foot alacritty kitty terminator gnome-terminal xterm; do
        if command -v "$t" >/dev/null 2>&1; then
            term="$t"
            break
        fi
    done

    if [ -z "$term" ]; then
        return 1
    fi

    case "$term" in
        foot)
            "$term" -e bash -lc "$cmd" &
            ;;
        alacritty)
            "$term" -e bash -lc "$cmd" &
            ;;
        kitty)
            "$term" bash -lc "$cmd" &
            ;;
        terminator)
            "$term" -e "bash -lc '$cmd'" &
            ;;
        gnome-terminal)
            "$term" -- bash -lc "$cmd" &
            ;;
        xterm)
            "$term" -e bash -lc "$cmd" &
            ;;
    esac
}

open_calendar() {
    if command -v gsimplecal >/dev/null 2>&1; then
        gsimplecal &
        return 0
    fi

    if command -v gnome-calendar >/dev/null 2>&1; then
        gnome-calendar &
        return 0
    fi

    if command -v yad >/dev/null 2>&1; then
        yad --calendar &
        return 0
    fi

    if command -v zenity >/dev/null 2>&1; then
        zenity --calendar &
        return 0
    fi

    open_term "cal -3"
}

case "$ACTION" in
    memory|cpu)
        if command -v btop >/dev/null 2>&1; then
            open_term "btop"
        elif command -v htop >/dev/null 2>&1; then
            open_term "htop"
        else
            open_term "top"
        fi
        ;;
    gpu)
        if command -v nvtop >/dev/null 2>&1; then
            open_term "nvtop"
        elif command -v radeontop >/dev/null 2>&1; then
            open_term "radeontop"
        elif command -v btop >/dev/null 2>&1; then
            open_term "btop"
        else
            open_term "top"
        fi
        ;;
    calendar)
        open_calendar
        ;;
    *)
        exit 1
        ;;
esac
