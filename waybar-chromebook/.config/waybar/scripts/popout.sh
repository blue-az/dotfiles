#!/bin/bash

set -euo pipefail

target="${1:-}"

has() {
    command -v "$1" >/dev/null 2>&1
}

run_first() {
    for cmd in "$@"; do
        if has "$cmd"; then
            "$cmd" >/dev/null 2>&1 &
            return 0
        fi
    done
    return 1
}

launch_terminal() {
    local title="${1:-popup}"
    shift || true

    if has foot; then
        foot --title "$title" -e sh -lc "$*; printf '\nPress Enter to close...'; read -r _" >/dev/null 2>&1 &
        return 0
    fi
    if has alacritty; then
        alacritty --title "$title" -e sh -lc "$*; printf '\nPress Enter to close...'; read -r _" >/dev/null 2>&1 &
        return 0
    fi
    if has kitty; then
        kitty --title "$title" sh -lc "$*; printf '\nPress Enter to close...'; read -r _" >/dev/null 2>&1 &
        return 0
    fi
    if has terminator; then
        terminator -T "$title" -e "sh -lc \"$*; printf '\nPress Enter to close...'; read -r _\"" >/dev/null 2>&1 &
        return 0
    fi
    return 1
}

open_calendar() {
    if run_first gsimplecal gnome-calendar; then
        return 0
    fi
    if has yad; then
        yad --calendar --title="Calendar" --undecorated --close-on-unfocus >/dev/null 2>&1 &
        return 0
    fi
    if has zenity; then
        zenity --calendar --title="Calendar" >/dev/null 2>&1 &
        return 0
    fi
    launch_terminal "calendar" "cal -3 || ncal -b -M"
}

open_network() {
    if has nm-connection-editor; then
        nm-connection-editor >/dev/null 2>&1 &
        return 0
    fi
    launch_terminal "network" "nmtui || nmcli device status"
}

open_audio() {
    if run_first pavucontrol helvum pwvucontrol; then
        return 0
    fi
    launch_terminal "audio" "wpctl status || pactl list short sinks"
}

open_system_monitor() {
    launch_terminal "system monitor" "btop || htop || top"
}

open_gpu_monitor() {
    launch_terminal "gpu monitor" "nvtop || btop || htop || top"
}

open_battery() {
    launch_terminal "battery" "upower -e | xargs -r -I{} upower -i {} || acpi -V"
}

open_brightness() {
    launch_terminal "brightness" "\
if command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m -c backlight >/dev/null 2>&1; then \
    brightnessctl -m -c backlight; \
elif command -v ddcutil >/dev/null 2>&1; then \
    ddcutil -d 2 getvcp 10 2>/dev/null || echo 'DDC brightness read failed'; \
else \
    echo 'No display brightness reader found'; \
fi"
}

case "$target" in
    calendar) open_calendar ;;
    network|wifi|ip) open_network ;;
    audio|vol|volume) open_audio ;;
    cpu|memory|ram|disk) open_system_monitor ;;
    gpu) open_gpu_monitor ;;
    battery) open_battery ;;
    brightness) open_brightness ;;
    *)
        launch_terminal "waybar popout" "echo 'Unknown target: $target'"
        ;;
esac
