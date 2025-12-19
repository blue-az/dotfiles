# IdeaPad U400 Setup (Debian 12)

## Fastfetch
```
blueaz@debian
-------------
OS: Debian GNU/Linux 12.12 (bookworm) x86_64
Host: 09932JU (Lenovo IdeaPad U400)
Kernel: Linux 6.1.0-41-amd64
Packages: 1945 (dpkg)
Shell: bash 5.2.15
Display (AUO303C): 1366x768 in 14", 60 Hz [Built-in]
WM: Sway (Wayland)
Terminal: claude
CPU: Intel(R) Core(TM) i5-2450M (4) @ 3.10 GHz
GPU 1: AMD Radeon HD 6400M/7400M Series
GPU 2: Intel 2nd Generation Core Processor Family Integrated Graphics Controller
Memory: ~6 GiB
Disk (/): 378 GiB - ext4
Local IP (wlp3s0): 192.168.8.x/24
Battery (L10N6P11)
```

## Hardware
- Lenovo IdeaPad U400
- Intel Core i5-2450M @ 2.50GHz (x86_64)
- AMD Radeon HD 6400M/7400M + Intel HD Graphics 3000
- 6GB RAM
- 14" 1366x768 display

## OS
- Debian GNU/Linux 12 (bookworm)
- Sway as primary WM

## Display Configuration
- eDP-1: 1366x768, scale 1

Config: `~/.dotfiles/sway-debian/.config/sway/config.d/outputs.conf.ideapad-u400`

## Network
- WiFi interface: wlp3s0
- Use nmcli for connections

## Power
- Battery: L10N6P11

## Config Locations
```
~/.dotfiles/sway-debian/.config/sway/config
~/.dotfiles/sway-debian/.config/sway/config.d/outputs.conf.ideapad-u400
~/.dotfiles/waybar/.config/waybar/config
~/.dotfiles/waybar/.config/waybar/style.css
~/.dotfiles/i3/.config/i3blocks/config
~/.dotfiles/bash/.bash_aliases
~/.dotfiles/xkb/.config/xkb/keymap (shared)
```

## Stow Packages
```bash
cd ~/.dotfiles
stow bash sway-debian waybar i3 nvim xkb wallpaper
```

Then symlink the outputs config:
```bash
cd ~/.config/sway/config.d
ln -sf outputs.conf.ideapad-u400 outputs.conf
```

## Differences from Fedora Machines
| Feature | Fedora (desktop/z13) | Debian (ideapad-u400) |
|---------|----------------------|------------------------|
| Launcher | wmenu-run | wofi |
| Sway config | sway | sway-debian |
| Wallpaper | FedoraDark.jpg | DebianDark.png |

## Bar Setup
- waybar: main status bar (bottom) + system overlay (top-right corner)

## Sensor Limitations
This older Sandy Bridge system has limited hardware monitoring:
- **CPU temp**: Works via coretemp (Core 0/1)
- **CPU power**: Intel RAPL exists but requires root access (`/sys/class/powercap/intel-rapl:0/energy_uj` is root-only)
- **GPU temp**: Radeon HD 6400M reports N/A via radeon driver (no HWMON support)
- **GPU utilization**: No `gpu_busy_percent` sysfs (requires amdgpu driver, not radeon)

The waybar scripts have been updated to gracefully hide unavailable metrics.

## To Start Sway
- From TTY: log out, switch to TTY (Ctrl+Alt+F2), run `sway`
- From display manager: select "Sway" session at login

## Aliases (notable)
| Alias | Command |
|-------|---------|
| `cl` | `claude` |
| `ff` | `fastfetch` |
| `jn` | `jupyter notebook` |
| `sbash` | `source ~/.bashrc` |
