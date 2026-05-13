# Z13 AMD Guidelines

## Machine Overview
- Host: ASUS ROG Flow Z13 (GZ302EA) on Fedora Linux 43 (Sway).
- Goal: match desktop configs; only diverge for display, power, WiFi, and GPU tooling.

## Stow Packages & Linking
- Primary packages:
  - `cd ~/.dotfiles`
  - `stow apps bash sway waybar i3 nvim xkb wallpaper`
- Sway outputs for this machine:
  - `ln -sf ~/.dotfiles/sway/.config/sway/config.d/outputs.conf.z13-amd ~/.config/sway/config.d/outputs.conf`
- Machine-specific sway overrides:
  - `ln -sf ~/.dotfiles/sway/.config/sway/config.d/machine.conf.z13-amd ~/.config/sway/config.d/machine.conf`
- Waybar config for this machine:
  - `ln -sf ~/.dotfiles/waybar/.config/waybar/config.z13-amd ~/.config/waybar/config`

## Display, Power, and Network
- Built-in panel: `eDP-1` at 2560x1600 with scale 1.9.
- Power nodes: `BAT0` and `AC0`.
- WiFi interface: `wlp194s0` (use `nmcli` for connections).

## GPU, NPU, and Sensors
- GPU: AMD Radeon 8050S (amdgpu). Utilization via:
  - `cat /sys/class/drm/card1/device/gpu_busy_percent`
- NPU is present (AMD Strix Halo); use only when explicitly supported by tooling.
- Auto-rotate should stay disabled. The old `sway-autorotate.service` could leave `eDP-1` stuck at `transform 90`; use manual Sway output commands if rotation is needed.

## Rear LED (DIY)
- DIY control files live in `machines/z13-amd/led/` (script, udev rule, systemd service, install steps).
- The udev rule uses group-scoped permissions (plugdev). Install steps are in `machines/z13-amd/led/INSTALL.md`.
- The repo-local `z13-restore.service` restores lightbar + keyboard to green if installed and enabled.
- This machine also has a separate system-level restore path outside the repo:
  - `/etc/systemd/system/gz302-rgb-restore.service`
  - `/usr/local/bin/gz302-rgb-restore`
  - `/usr/lib/systemd/system-sleep/gz302-reset.sh`
- That external restore path re-applies the saved rear lightbar state from `/etc/gz302/rgb-window.conf` on boot and after resume, and can override the repo-local expectations.

## Validation Notes
- After changes, reload `sway` and `waybar` to confirm outputs, bar layout, and battery stats.
- Keep any machine-only overrides isolated to `outputs.conf.z13-amd` or clearly marked sections.
