# Chromebook Lenovo Setup (Debian 12 - Penguin)

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
blueaz@penguin
--------------
OS: Debian GNU/Linux 12.12 (bookworm) x86_64
Host: crosvm (Lenovo Chromebook)
Kernel: Linux 6.6.99-08726-g28eab9a1f61e
Packages: 1842 (dpkg)
Shell: bash 5.2.15
Display: 3072x1728 @ 2x in 13", 60 Hz
Terminal: claude
CPU: Intel Core i3-10110U (4) @ 2.59 GHz
Memory: ~2.69 GiB
Disk (/): 20 GiB - btrfs
Battery: Chromebook battery
```

## Hardware
- Lenovo Chromebook (x86_64)
- Intel Core i3-10110U
- Runs in Crostini/Penguin Linux container

## Environment
- No window manager (uses ChromeOS desktop)
- Terminal-focused workflow
- Claude Code as primary interface

## Installed Tools
- neovim (from /opt/nvim-linux64/)
- git, curl, wget
- stow, fzf
- miniconda3
- avahi-daemon (for mDNS/hostname resolution)
- tigervnc-viewer, ssvnc (for cb-link)

## Config Locations
```
~/.bashrc           - Shell config with vi mode
~/.bash_aliases     - Chromebook-specific aliases
~/.config/nvim/init.lua - Neovim config (matches other machines)
~/.fzf.bash         - fzf integration
```

## Key Features
- Vi mode in bash (`set -o vi`)
- nvim as default editor
- fzf for history (Ctrl+R) and file search (Ctrl+T)
- Python venv at ~/Python/.venv/

## Aliases
| Alias | Command |
|-------|---------|
| `cl` | `claude` |
| `ff` | `fastfetch` |
| `ll` | `ls -halF` |
| `jn` | `jupyter notebook` |
| `sbash` | `source ~/.bashrc` |
| `AVE` | Activate Python venv |

## cb-link Client Aliases (for Z13 connection)
| Alias | Command |
|-------|---------|
| `cbv` / `cbc` | Connect to AMD Z13 |
| `cbcf` | Fullscreen connect |
| `cbcm` | Mirror mode connect |
| `cbcd` | Disconnect |
| `cbcs` | Status |

## Setup Notes
- Sway not used (ChromeOS provides desktop)
- Downloads folder is symlinked to ChromeOS: ~/Downloads -> /mnt/chromeos/MyFiles/Downloads/
- Google Drive available at ~/GoogHome

## To Do
- [ ] Clone and configure cb-link scripts
