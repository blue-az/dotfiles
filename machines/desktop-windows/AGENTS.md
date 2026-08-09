# Desktop Windows Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points and issue tracking).

## Machine Overview
- Host: `windows` (Desktop hardware booted into Windows 11)
- OS: Windows 11
- Goal: Mirror Linux Sway experience using Komorebi tiling WM, Git Bash, and Neovim.

## Stow / Config Locations
- Keybindings: `~/.config/whkdrc`
- Komorebi config: `~/komorebi.json` and `~/komorebi.bar.json`
- Shell config: `~/.bashrc`, `~/.bash_aliases`

## Machine-Specific Notes
- Display: Triple monitor setup
- GPU: NVIDIA GeForce RTX 3090
- WM: komorebi + whkd + komorebi-bar + masir
- Mod key: Caps Lock (remapped to Right Alt via PowerToys)

## Validation Notes
- Reload komorebi/whkd via komorebic restart or whkd restart.
