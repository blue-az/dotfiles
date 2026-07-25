# IdeaPad U400 Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points and issue tracking).

## Machine Overview
- Host: `debian` (Lenovo IdeaPad U400)
- OS: Debian GNU/Linux 12 (bookworm) x86_64
- Goal: Sway/Wayland setup on legacy Intel + AMD hybrid laptop hardware.

## Stow Packages & Linking
- Packages: `sway-debian` (or `sway`), `bash`, `nvim`, `waybar`
- Command: `cd ~/.dotfiles && stow sway-debian bash nvim`

## Machine-Specific Notes
- Display: 1366x768 (14" built-in AUO panel)
- GPU: Dual graphics - Intel HD 3000 + AMD Radeon HD 6400M/7400M
- WM: Sway (Wayland)

## Validation Notes
- Sway reload: `swaymsg reload`
