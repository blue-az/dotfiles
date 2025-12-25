# Desktop Windows Setup (Windows 11)

## Overview
Windows desktop configured to mirror the Linux Sway/i3 experience using komorebi tiling WM.

## Hardware
- Same hardware as Linux desktop
- Intel Core i9-9900KF @ 3.60GHz (x86_64)
- NVIDIA GeForce RTX 3090
- 64GB RAM
- Triple monitor setup

## OS
- Windows 11
- Shell: Git Bash (MSYS2)

## Tiling WM Stack
| Component | Purpose |
|-----------|---------|
| komorebi | Tiling window manager (like Sway/i3) |
| whkd | Hotkey daemon (like skhd) |
| komorebi-bar | Status bar (like waybar) |
| masir | Focus-follows-mouse |

## Config Locations
```
~/.bashrc                      # Shell config (vi mode, aliases)
~/.bash_aliases                # Command aliases
~/.config/whkdrc               # Hotkey bindings
~/komorebi.json                # WM config
~/komorebi.bar.json            # Status bar config
~/AppData/Local/nvim/init.lua  # Neovim config
```

## Keybindings
Mod key: **Caps Lock** (remapped to Right Alt via PowerToys)

| Binding | Action |
|---------|--------|
| Caps + hjkl | Focus windows |
| Caps + Shift + hjkl | Move windows |
| Caps + Ctrl + hjkl | Resize windows |
| Caps + 1-0 | Switch workspace |
| Caps + Shift + 1-0 | Move to workspace |
| Caps + f | Fullscreen (monocle) |
| Caps + Shift + Space | Toggle float |
| Caps + Shift + q | Close window |
| Caps + e | Flip layout |
| Caps + Shift + c | Reload config |

## Starting Komorebi
```powershell
# Full start with bar and focus-follows-mouse
& "C:\Program Files\komorebi\bin\komorebic.exe" start --whkd --bar --masir
```

Auto-start: `shell:startup\komorebi.bat`

## Installed Tools
- Neovim 0.11.5
- Python 3.14
- Git 2.52.0
- fzf, ripgrep
- PowerToys (keyboard remapping)

## Shell Settings
- Vi mode enabled (`set -o vi`)
- Prompt: green user@windows, blue path
- Editor: nvim

## Aliases (notable)
| Alias | Command |
|-------|---------|
| `cl` | `claude` |
| `vim`, `vi` | `nvim` |
| `ll` | `ls -halF` |
| `gs` | `git status` |
| `docs` | `cd ~/OneDrive/Documents` |

## Known Limitations
- Bar only displays on monitor 0
- Focus-follows-mouse works on monitor 0 only
- Some Windows system shortcuts may conflict with keybindings

## Differences from Linux Desktop
| Feature | Linux (Sway) | Windows (komorebi) |
|---------|--------------|-------------------|
| Mod key | Super (Caps swapped) | Caps Lock → Right Alt |
| Bar | waybar | komorebi-bar |
| Focus-follows-mouse | Built-in | masir |
| Shell | bash | Git Bash |
| Config format | Text | JSON |
