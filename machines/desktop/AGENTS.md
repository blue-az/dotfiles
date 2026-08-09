# desktop Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points, issue tracking in `ISSUES.md`, and bottleneck resolution).

## Machine Overview
- Host: `desktop`
- OS: Fedora Linux (Sway as primary WM)
- Goal: Keep desktop behavior stable while reducing config sprawl and duplication.

## Stow Packages & Linking
- Packages: `stow --no-folding bash sway waybar i3 shared nvim xkb x11 wallpaper`
- Outputs/config links (both are untracked per-machine pointers — recreate them
  after a fresh clone, and after the commit that untracked `machine.conf`):
  - `ln -sf outputs.conf.desktop ~/.config/sway/config.d/outputs.conf`
  - `ln -sf machine.conf.desktop ~/.config/sway/config.d/machine.conf`
  - Sway hard-includes both (`sway/.config/sway/config` lines 27 and 35), so a
    missing pointer means the desktop loses those overrides on reload.
- Waybar config: this machine uses the generic `waybar/.config/waybar/config`
  directly — no pointer symlink, and do not repoint it at a `config.<machine>`
  variant.
- Use `--no-folding` so `~/.config/<pkg>` stays a real directory. If stow folds
  it into a symlink, the `ln -sf` lines above write into `~/.dotfiles` and
  convert tracked files into machine-specific symlinks. Verify with
  `ls -ld ~/.config/sway` — a directory is correct, a symlink is not.

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
  - OpenClaw gateway user units live in `machines/desktop/openclaw/`, outside
    every stow package, because they hardcode `/home/blueaz/.openclaw/...` and
    would otherwise be linked on every host that stows `sway`. Install them with
    `machines/desktop/openclaw/INSTALL.md`; that file also records which of the
    two ollama profiles still needs to be identified and removed.

## Validation Notes
- What to reload/restart after changes:
  - Sway config: `swaymsg reload`
  - Waybar scripts/config: `pkill -SIGUSR2 waybar` (or restart waybar)
