# Mac Mini Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points and issue tracking).

## Machine Overview
- Host: `Mac-mini` (Mac mini 2018)
- OS: macOS Sequoia 15.7.2 (x86_64)
- Goal: Serve as real-time data collection hub (Garmin, Apple Watch, iPhone video extraction) and stroke classifier training node.

## Stow Packages & Linking
- Packages: `macos` (contains `yabai`, `skhd`, `zsh` configs)
- Target directory on macOS: `~/dotfiles` (cloned without leading dot on macOS)
- Command: `cd ~/dotfiles && stow macos`

## Machine-Specific Notes
- Display: Acer Predator XB271HU (2560x1440 @ 144Hz native / 165Hz OC)
- Window Management: yabai (tiling WM) + skhd (hotkey daemon)
- Keybindings: Caps Lock remapped to Cmd / Super key
- Services: `yabai --start-service`, `skhd --start-service`

## Validation Notes
- After changes to yabai/skhd: `yabai --restart-service` or `skhd --restart-service`
