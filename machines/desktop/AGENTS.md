# desktop Guidelines

## Machine Overview
- Host: `desktop`
- OS: Fedora Linux (Sway as primary WM)
- Goal: Keep desktop behavior stable while reducing config sprawl and duplication.

## Stow Packages & Linking
- Packages: `bash sway waybar i3 shared nvim xkb x11 wallpaper`
- Outputs/config links:
  - Sway outputs: `sway/.config/sway/config.d/outputs.conf.desktop`
  - Waybar config: `waybar/.config/waybar/config`

## Machine-Specific Notes
- Display:
  - Main outputs are managed in `outputs.conf.desktop`.
  - Screenshot binding: `Shift+Print` captures focused output.
- Network:
  - Prefer generalized scripts in `waybar/.config/waybar/scripts/`.
- Power:
  - Brightness DDC helper lives at `~/.config/shared/scripts/brightness-ddc.sh`.
- GPU/accelerators:
  - NVIDIA tooling is expected (`nvidia-smi` paths in scripts).
- Services:
  - Keep custom machine services documented in `machines/desktop/CLAUDE.md`.

## Validation Notes
- What to reload/restart after changes:
  - Sway config: `swaymsg reload`
  - Waybar scripts/config: `pkill -SIGUSR2 waybar` (or restart waybar)
