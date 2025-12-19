# Desktop Setup (Fedora 43)

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
blueaz@desktop
--------------
OS: Fedora Linux 43 (KDE Plasma Desktop Edition) x86_64
Host: MS-7B51 (1.0)
Kernel: Linux 6.17.8-300.fc43.x86_64
Uptime: 8 days, 17 hours, 34 mins
Packages: 3627 (rpm), 15 (flatpak)
Shell: bash 5.3.0
Display (XB271HU): 2560x1440 @ 144 Hz in 27" [External]
Display (Acer AL2216W): 1680x1050 @ 60 Hz in 22" [External]
Display (LG TV): 1920x1080 @ 60 Hz in 7" [External]
DE: sway:wlroots
WM: Sway 1.11 (Wayland)
Theme: Breeze [GTK3]
Icons: breeze [GTK3/4]
Font: Noto Sans (10pt) [GTK3/4]
Cursor: breeze (24px)
Terminal: claude
CPU: Intel(R) Core(TM) i9-9900KF (16) @ 5.00 GHz
GPU: NVIDIA GeForce RTX 3090 [Discrete]
Memory: 8.55 GiB / 62.72 GiB (14%)
Swap: 0 B / 8.00 GiB (0%)
Disk (/): 444.72 GiB / 488.16 GiB (91%) - btrfs
Local IP (eno1): 192.168.8.178/24
Locale: en_US.UTF-8
```

## Hardware
- Intel Core i9-9900KF @ 3.60GHz (x86_64)
- NVIDIA GeForce RTX 3090
- 64GB RAM
- Triple monitor setup (DP-1, DP-2, DP-3)

## OS
- Fedora Linux 43 (KDE Plasma Desktop Edition)
- Sway as primary WM

## Display Configuration
- DP-2: Primary (2560x1440) - workspace 1
- DP-3: Secondary (1680x1050) - workspace 2
- DP-1: Disabled by default

Config: `~/.dotfiles/sway/.config/sway/config.d/outputs.conf.desktop`

## Config Locations
```
~/.dotfiles/sway/.config/sway/config
~/.dotfiles/sway/.config/sway/config.d/outputs.conf.desktop
~/.dotfiles/waybar/.config/waybar/config
~/.dotfiles/waybar/.config/waybar/style.css
~/.dotfiles/i3/.config/i3blocks/config
~/.dotfiles/bash/.bash_aliases
~/.dotfiles/xkb/.config/xkb/keymap (shared)
~/.dotfiles/xkb/.config/xkb/symbols/custom (shared)
```

## Stow Packages
```bash
cd ~/.dotfiles
stow bash sway waybar i3 nvim xkb x11 wallpaper
```

## Screen Layout Shortcuts
- `$mod+F2`: 2-screen layout
- `$mod+F3`: 3-screen layout

## GPU
- NVIDIA proprietary driver
- `nvidia-smi` for monitoring
- CUDA available for ML workloads

## Aliases (notable)
| Alias | Command |
|-------|---------|
| `cl` | `claude` |
| `ff` | `fastfetch` |
| `nv` | `nvidia-smi` |
| `OW` | Open WebUI (Docker with CUDA) |
| `g3` | `ollama run gemma3:27b` |
| `1s/2s/3s` | Screen layouts |

## Bar Setup
- i3blocks: main status bar (bottom)
- waybar: system overlay (top-right corner)
