# Sway Setup on Chromebook (Debian 12)

## Hardware
- Samsung Chromebook Plus v1 ("Kevin")
- Rockchip RK3399 SoC (ARM64)
- Mali T860 GPU (Panfrost driver)
- Battery: /sys/class/power_supply/sbs-9-000b

## Completed
- Created `sway-chromebook` config in dotfiles (separate from desktop/z13 laptop configs)
- Created `waybar-chromebook` config with overlay (matches desktop setup)
- Created `i3blocks-chromebook` config (matches desktop setup)
- Installed: sway, waybar, swaylock, swayidle, wofi, grim, slurp, wl-clipboard, dunst, terminator, brightnessctl, pulseaudio-utils, i3blocks, jq, dbus-x11
- Symlinked configs to ~/.config/

## Config locations
```
~/.dotfiles/sway-chromebook/.config/sway/config
~/.dotfiles/waybar-chromebook/.config/waybar/config
~/.dotfiles/waybar-chromebook/.config/waybar/config-overlay
~/.dotfiles/waybar-chromebook/.config/waybar/style.css
~/.dotfiles/waybar-chromebook/.config/waybar/style-overlay.css
~/.dotfiles/waybar-chromebook/.config/waybar/sysinfo.sh
~/.dotfiles/waybar-chromebook/.config/waybar/start-overlay.sh
~/.dotfiles/i3blocks-chromebook/.config/i3blocks/config
~/.dotfiles/xkb/.config/xkb/keymap (shared)
~/.dotfiles/xkb/.config/xkb/symbols/custom (shared)
```

## Chromebook-specific settings
- Output: eDP-1
- WiFi interface: mlan0 (use nmcli for SSID, /proc/net/wireless for signal)
- Launcher: wofi (wmenu not in Debian 12 repos)
- Natural scroll enabled on touchpad
- Brightness/volume keys configured
- GPU stats: frequency-based % (cur_freq/max_freq from /sys/class/devfreq/ff9a0000.gpu)
- Thermal zones: thermal_zone0 (CPU), thermal_zone1 (GPU)

## Bar setup (matches desktop)
- i3blocks: main status bar (bottom)
- waybar: system overlay (top-right corner)

## To start sway
- From TTY: log out, switch to TTY (Ctrl+Alt+F2), run `sway`
- From display manager: select "Sway" session at login

## Working
- Sway launch via lightdm
- Keyboard layout (caps/super swap)
- i3blocks status bar
- Waybar overlay
- Screenshot bindings
- Brightness/volume keys
- WiFi display (nmcli)
- Battery display
- GPU/CPU temp and usage
