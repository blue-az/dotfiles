# Z13 AMD Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points, issue tracking in `ISSUES.md`, and bottleneck resolution).

## Machine Overview
- Host: ASUS ROG Flow Z13 (GZ302EA) on Fedora Linux 43 (Sway).
- Goal: match desktop configs; only diverge for display, power, WiFi, and GPU tooling.

## Stow Packages & Linking
- Primary packages:
  - `cd ~/.dotfiles`
  - `stow apps audio bash sway waybar i3 nvim xkb wallpaper`
- Bash machine aliases are loaded from `machines/z13-amd/bash_aliases` when the host reports `z13` (or the legacy hostname `fedora`).
- Sway outputs for this machine:
  - `ln -sf ~/.dotfiles/sway/.config/sway/config.d/outputs.conf.z13-amd ~/.config/sway/config.d/outputs.conf`
- Machine-specific sway overrides:
  - `ln -sf ~/.dotfiles/sway/.config/sway/config.d/machine.conf.z13-amd ~/.config/sway/config.d/machine.conf`
- Waybar config for this machine:
  - `stow --no-folding waybar` (required — see below)
  - `ln -sf ~/.dotfiles/waybar/.config/waybar/config.z13-amd ~/.config/waybar/config`
- **Stow folding vs. the `ln -sf` overrides above.** Plain `stow <pkg>` folds a
  package whose target directory does not exist yet: `~/.config/waybar` becomes
  a single symlink *into the repo*, so the `ln -sf` lines above then write the
  machine symlink inside `~/.dotfiles` and convert a tracked file into a
  symlink. For waybar that silently replaces the generic `config` (which the
  desktop uses per `machines/desktop/AGENTS.md`) with a link to the Z13 variant.
  Any package that carries `<name>.<machine>` variants must be stowed with
  `--no-folding` so the override symlink lives in `~/.config`, outside the repo.
  Check with `ls -ld ~/.config/<pkg>`: a directory is correct, a symlink is not.

## Display, Power, and Network
- Built-in panel: `eDP-1` at 2560x1600 with scale 1.9.
- Power nodes: `BAT0` and `AC0`.
- WiFi interface: `wlp194s0` (use `nmcli` for connections).

## Audio
- Sinks: built-in analog is `alsa_output.pci-0000_c4_00.6.analog-stereo`; the
  external display is `alsa_output.pci-0000_c4_00.1.hdmi-stereo-extra1`
  (card `alsa_card.pci-0000_c4_00.1`, port `hdmi-output-1`).
- The `audio` stow package raises HDMI/DP session priority above analog so the
  display is re-selected automatically after it is unplugged and plugged back
  in. Without it, analog outranks HDMI (1009 vs 632) and sound stays on the
  laptop speakers.
- That rule is pinned to this machine's Radeon audio card (`pci-0000_c4_00.1`),
  so it is inert on any other host. Do not stow `audio` on the desktop: sink
  selection there goes through `cycle-audio-source.sh` and a static priority
  override would fight it.
- Caveat: because HDMI now outranks analog, plugging in headphones will *not*
  auto-switch away from the display. Switch manually with `pavucontrol` or
  `pactl set-default-sink`.

## GPU, NPU, and Sensors
- GPU: AMD Radeon 8050S (amdgpu). Utilization via:
  - `cat /sys/class/drm/card1/device/gpu_busy_percent`
- NPU is present (AMD Strix Halo); use only when explicitly supported by tooling.
- Auto-rotate is deprecated and removed; use manual Sway output commands if rotation is ever needed.

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
