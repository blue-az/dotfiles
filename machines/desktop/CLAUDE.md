# Desktop Setup (Fedora 43)

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
