# Z13 Windows Setup (Windows 11)

## Fastfetch
```
efehn@z13
---------
OS: Windows 11 Home (25H2) x86_64
Host: ROG Flow Z13 GZ302EA_GZ302EA (1.0)
Kernel: WIN32_NT 10.0.26200.7462
Packages: 20 (choco)
Shell: bash 5.2.37
Display (TL134ADXP03): 1920x1080 in 13", 180 Hz [Built-in]
WM: Desktop Window Manager
Terminal: xterm-256color
CPU: AMD RYZEN AI MAX 390 (24) @ 5.05 GHz
GPU: AMD Radeon(TM) 8050S Graphics (3.78 GiB) [Integrated]
Memory: 11.84 GiB / 27.65 GiB (43%)
Disk (C:\): 372.14 GiB / 620.71 GiB (60%) - NTFS
Local IP (Wi-Fi): 192.168.8.153/24
Battery: 100% [AC Connected]
Locale: en-US
```

## Overview
Windows 11 on ASUS ROG Flow Z13 (AMD), configured to mirror the Linux Sway/i3 experience using komorebi tiling WM.

## Hardware
- ASUS ROG Flow Z13 (GZ302EA) - AMD version
- AMD Ryzen AI MAX 390 w/ Radeon 8050S (24 threads)
- AMD Strix Halo integrated GPU (Radeon 8050S)
- 27GB RAM (shared with GPU)
- 2-in-1 convertible tablet/laptop

## OS
- Windows 11 Home (25H2)
- Shell: Git Bash (MSYS2)

## Tiling WM Stack
| Component | Purpose |
|-----------|---------|
| komorebi | Tiling window manager (like Sway/i3) |
| whkd | Hotkey daemon (runs as admin via Task Scheduler) |
| komorebi-bar | Status bar (Catppuccin Mocha theme) |
| masir | Focus-follows-mouse |

## Config Locations
```
~/.bashrc                      # Shell config (vi mode, aliases)
~/.bash_aliases                # Command aliases
~/whkdrc                       # Hotkey bindings
~/komorebi.json                # WM config
~/komorebi.bar.json            # Status bar config
~/applications.json            # App-specific rules
~/AppData/Local/nvim/init.lua  # Neovim config
```

## Keybindings
Mod key: **Alt**

| Binding | Action |
|---------|--------|
| Alt + hjkl | Focus windows |
| Alt + Shift + hjkl | Move windows |
| Alt + 1-0 | Switch workspace |
| Alt + Shift + 1-0 | Move to workspace |
| Alt + f | Fullscreen (monocle) |
| Alt + Shift + Space | Toggle float |
| Alt + Shift + q | Close window |
| Alt + e | Flip layout horizontal |
| Alt + Shift + c | Reload config |
| Alt + Shift + p | Toggle pause |
| Alt + Return | Promote to main |

## Starting Komorebi
Automatic via:
- `shell:startup\komorebi.bat` - Starts komorebi, bar, masir
- Task Scheduler "whkd" task - Starts whkd with admin privileges

Manual start:
```powershell
& "C:\Program Files\komorebi\bin\komorebic.exe" start --bar --masir
Start-Process "C:\Program Files\whkd\bin\whkd.exe" -Verb RunAs
```

## Installed Tools
- komorebi 0.1.39
- whkd 0.2.10
- masir 0.1.2
- Neovim 0.11.5
- Python 3.14
- Git 2.52.0
- PowerToys 0.96.1
- fastfetch 2.56.0

## Shell Settings
- Vi mode enabled (`set -o vi`)
- Prompt: green user@z13, blue path
- Editor: nvim

## Aliases (notable)
| Alias | Command |
|-------|---------|
| `cl` | `claude` |
| `ff` | `fastfetch` |
| `vim`, `vi` | `nvim` |
| `ll` | `ls -halF` |
| `gs` | `git status` |
| `docs` | `cd ~/OneDrive/Documents` |
| `kstart` | Start komorebi |
| `kstop` | Stop komorebi |
| `kreload` | Reload komorebi config |

## Bar Configuration
- Theme: Catppuccin Mocha
- Accent: Green
- Position: Top of screen
- Widgets: Workspaces, Layout, Date, Time, Memory, Battery

## Known Issues
- whkd requires admin privileges to capture global hotkeys
- Bar only displays on primary monitor

## Differences from Linux Z13 (Fedora/Sway)
| Feature | Linux (Sway) | Windows (komorebi) |
|---------|--------------|-------------------|
| Mod key | Super | Alt |
| Bar | waybar | komorebi-bar |
| Focus-follows-mouse | Built-in | masir |
| Shell | bash | Git Bash |
| Config format | Text | JSON |
| Auto-rotate | sway-autorotate | Not available |
