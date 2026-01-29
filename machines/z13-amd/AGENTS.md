# Z13 AMD Guidelines

## Machine Overview
- Host: ASUS ROG Flow Z13 (GZ302EA) on Fedora Linux 43 (Sway).
- Goal: match desktop configs; only diverge for display, power, WiFi, and GPU tooling.

## Stow Packages & Linking
- Primary packages:
  - `cd ~/.dotfiles`
  - `stow bash sway waybar i3 nvim xkb wallpaper`
- Sway outputs for this machine:
  - `ln -sf ~/.dotfiles/sway/.config/sway/config.d/outputs.conf.z13-amd ~/.config/sway/config.d/outputs.conf`

## Display, Power, and Network
- Built-in panel: `eDP-1` at 2560x1600 with scale 1.9.
- Power nodes: `BAT0` and `AC0`.
- WiFi interface: `wlp194s0` (use `nmcli` for connections).

## GPU, NPU, and Sensors
- GPU: AMD Radeon 8050S (amdgpu). Utilization via:
  - `cat /sys/class/drm/card1/device/gpu_busy_percent`
- NPU is present (AMD Strix Halo); use only when explicitly supported by tooling.
- Auto-rotate is enabled via `~/.local/bin/sway-autorotate` and `~/.config/systemd/user/sway-autorotate.service`.

## Rear LED (DIY)
- DIY control files live in `machines/z13-amd/led/` (script, udev rule, systemd service, install steps).
- The udev rule uses group-scoped permissions (plugdev). Install steps are in `machines/z13-amd/led/INSTALL.md`.
- Current defaults restore lightbar + keyboard to green on boot/resume; adjust RGB in the service if desired.

## Validation Notes
- After changes, reload `sway` and `waybar` to confirm outputs, bar layout, and battery stats.
- Keep any machine-only overrides isolated to `outputs.conf.z13-amd` or clearly marked sections.
