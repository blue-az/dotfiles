# Sway Setup on Chromebook Kevin (Debian 12)

## Dotfiles Repository
```
Git:   https://github.com/blue-az/dotfiles.git
Local: ~/.dotfiles
```
```bash
git clone https://github.com/blue-az/dotfiles.git ~/.dotfiles
```

## Fastfetch
```
OS: Debian GNU/Linux 12.12 (bookworm) aarch64
Host: Google Kevin
Kernel: Linux 6.1.51-stb-cbg+
Packages: 1632 (dpkg), 5 (flatpak)
Shell: bash 5.2.15
Display (eDP-1): 2400x1600 @ 1.5x in 12", 60 Hz [Built-in]
WM: Sway 1.7 (Wayland)
Terminal: claude
CPU: rk3399 (6) @ 2.02 GHz
GPU: Rockchip rk3399-mali [Integrated]
Memory: 1.01 GiB / 3.78 GiB (27%)
Swap: 0 B / 512.00 MiB (0%)
Disk (/): 7.97 GiB / 29.16 GiB (27%) - btrfs
Local IP (mlan0): 192.168.8.187/24
Battery (4352D51): 71% [Discharging]
```

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

## Config Locations
```
~/.dotfiles/sway-chromebook/.config/sway/config
~/.dotfiles/waybar-chromebook/.config/waybar/config
~/.dotfiles/waybar-chromebook/.config/waybar/config-overlay
~/.dotfiles/waybar-chromebook/.config/waybar/style.css
~/.dotfiles/waybar-chromebook/.config/waybar/style-overlay.css
~/.dotfiles/waybar-chromebook/.config/waybar/sysinfo.sh
~/.dotfiles/waybar-chromebook/.config/waybar/start-overlay.sh
~/.dotfiles/i3blocks-chromebook/.config/i3blocks/config
~/.dotfiles/xkb-chromebook/.config/xkb/keymap (Chromebook-specific, Search=Mod4)
```

## Chromebook-specific settings
- Output: eDP-1
- WiFi interface: mlan0 (use nmcli for SSID, /proc/net/wireless for signal)
- Launcher: wofi (wmenu not in Debian 12 repos)
- Natural scroll enabled on touchpad
- Brightness/volume keys configured
- GPU stats: frequency-based % (cur_freq/max_freq from /sys/class/devfreq/ff9a0000.gpu)
- Thermal zones: thermal_zone0 (CPU), thermal_zone1 (GPU)

## Bar Setup (matches desktop)
- i3blocks: main status bar (bottom)
- waybar: system overlay (top-right corner)

## To start sway
- From TTY: log out, switch to TTY (Ctrl+Alt+F2), run `sway`
- From display manager: select "Sway" session at login

## Working
- Sway launch via lightdm
- Keyboard layout (Search key = Mod4, use `stow xkb-chromebook` NOT `stow xkb`)
- i3blocks status bar
- Waybar overlay
- Screenshot bindings
- Brightness/volume keys
- WiFi display (nmcli)
- Battery display
- GPU/CPU temp and usage
