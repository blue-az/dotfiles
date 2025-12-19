# Z13 AMD Setup (Fedora 43)

## Fastfetch
```
blueaz@fedora
-------------
OS: Fedora Linux 43 (Sway) x86_64
Host: ROG Flow Z13 GZ302EA_GZ302EA (1.0)
Kernel: Linux 6.17.11-300.fc43.x86_64
Uptime: 9 mins
Packages: 1847 (rpm), 10 (flatpak)
Shell: bash 5.3.0
Display (TL134ADXP03): 2560x1600 @ 180 Hz (as 1348x843) in 13" [Built-in]
WM: Sway 1.11 (Wayland)
Cursor: Adwaita
Terminal: claude
CPU: AMD RYZEN AI MAX 390 (24) @ 5.06 GHz
GPU: AMD Radeon 8050S Graphics [Integrated]
Memory: 1.78 GiB / 27.04 GiB (7%)
Swap: 0 B / 8.00 GiB (0%)
Disk (/): 10.22 GiB / 300.46 GiB (3%) - btrfs
Local IP (wlp194s0): 192.168.8.116/24
Battery (ASUS Battery): 100% [Discharging]
Locale: en_US.UTF-8
```

## Hardware
- ASUS ROG Flow Z13 (GZ302EA) - AMD version
- AMD Ryzen AI MAX 390 w/ Radeon 8050S (24 threads)
- AMD Strix Halo integrated GPU (Radeon 8050S)
- AMD NPU (Neural Processing Unit)
- 27GB RAM (shared with GPU)
- 2-in-1 convertible tablet/laptop

## OS
- Fedora Linux 43 (Sway)
- Kernel: Linux 6.17.x

## Display Configuration
- eDP-1: 2560x1600, scale 1.9 (effective ~1347x842)

Config: `~/.dotfiles/sway/.config/sway/config.d/outputs.conf.z13-amd`

## Network
- WiFi interface: wlp194s0
- Use nmcli for connections

## Power
- Battery: BAT0
- AC: AC0

## Thermal Zones
- thermal_zone0: acpitz (CPU)
- thermal_zone1, thermal_zone2: additional zones

## Config Locations
```
~/.dotfiles/sway/.config/sway/config
~/.dotfiles/sway/.config/sway/config.d/outputs.conf.z13-amd
~/.dotfiles/waybar/.config/waybar/config
~/.dotfiles/waybar/.config/waybar/style.css
~/.dotfiles/i3/.config/i3blocks/config
~/.dotfiles/bash/.bash_aliases
~/.dotfiles/xkb/.config/xkb/keymap (shared)
```

## Stow Packages
```bash
cd ~/.dotfiles
stow bash sway waybar i3 nvim xkb wallpaper
```

Then symlink the outputs config:
```bash
cd ~/.config/sway/config.d
ln -sf outputs.conf.z13-amd outputs.conf
```

## GPU
- AMD Radeon 8050S (integrated, uses amdgpu driver)
- `cat /sys/class/drm/card1/device/gpu_busy_percent` for utilization
- Shares system RAM (no discrete VRAM)

## NPU (AI Accelerator)
- AMD Strix Halo Neural Processing Unit at c5:00.1
- For ML/AI workloads when supported

## Auto-Rotate
Uses same sway-autorotate script as Intel Z13:
- Script: `~/.local/bin/sway-autorotate`
- Service: `~/.config/systemd/user/sway-autorotate.service`
- Accelerometer: `/sys/bus/iio/devices/iio:device0/`

## Notable Differences from Intel Z13
| Feature | Intel Z13 | AMD Z13 |
|---------|-----------|---------|
| CPU | Intel Core | AMD Ryzen AI MAX 390 |
| GPU | Intel Iris + NVIDIA | AMD Radeon 8050S |
| RAM | Dedicated | Shared with GPU |
| NPU | None | AMD Strix Halo NPU |
| WiFi | Different | wlp194s0 |
