# Z13 Windows Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points and issue tracking).

## Machine Overview
- Host: `z13` (ASUS ROG Flow Z13 booted into Windows 11 Home 25H2)
- OS: Windows 11 Home
- Goal: Mirror Linux Sway experience on Z13 hardware using Komorebi tiling WM.

## Stow / Config Locations
- Config files live in `machines/z13-windows/` (`komorebi.json`, `komorebi.bar.json`, `whkdrc`, `applications.json`).

## Machine-Specific Notes
- Hardware: AMD Ryzen AI MAX 390 with Radeon 8050S (Strix Halo)
- Display: 1920x1080 @ 180Hz built-in panel
- WM: komorebi + whkd + komorebi-bar

## Validation Notes
- Restart komorebi/whkd daemon when modifying json/whkdrc configs.
