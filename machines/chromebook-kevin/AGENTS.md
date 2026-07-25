# Chromebook Kevin Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points and issue tracking).

## Machine Overview
- Host: Samsung Chromebook Plus v1 ("Kevin")
- OS: Debian GNU/Linux 12 (bookworm) aarch64 (ARM64, kernel 6.1)
- Goal: Lightweight native ARM64 Sway/Wayland setup.

## Stow Packages & Linking
- Packages: `sway-chromebook`, `waybar-chromebook`, `i3blocks-chromebook`, `bash`, `nvim`
- Command: `cd ~/.dotfiles && stow sway-chromebook waybar-chromebook bash`

## Machine-Specific Notes
- Display: Built-in 2400x1600 @ 1.5x scale (12")
- GPU: Rockchip RK3399 Mali T860 (Panfrost driver)
- Battery: `/sys/class/power_supply/sbs-9-000b`
- WM: Sway 1.7 (Wayland) using dedicated `sway-chromebook` configs

## Validation Notes
- Sway config reload: `swaymsg reload`
