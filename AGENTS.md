# Repository Guidelines

## Project Structure & Module Organization
- Top-level folders are stow packages for dotfiles (e.g., `bash/`, `nvim/`, `sway/`, `waybar/`, `xkb/`, `wallpaper/`, `x11/`, `macos/`). Each package mirrors the target path under `$HOME` (for example `sway/.config/sway/`).
- Hardware- and OS-specific notes live in `machines/` (per host) and `devices/` (phones/tablets). Monitor presets are in `monitors/`.
- Issues and setup references are documented in `ISSUES.md` and the various `CLAUDE.md` or `README.md` files.
## Machine-Specific Guides
- Host-level contributor notes live in `machines/<name>/AGENTS.md`. Use these for per-machine stow sets, output configs, and device-specific quirks.
- Z13 AMD guide: `machines/z13-amd/AGENTS.md`.
## Current Machine (Agent Note)
- To identify the host, run: `hostnamectl --static` (preferred) or `cat /etc/hostname`.
- Use that name to open `machines/<name>/AGENTS.md` for any machine-specific instructions; if it doesn't exist, create it.
- Template for a new machine guide:
```md
# <Machine Name> Guidelines

## Machine Overview
- Host:
- OS:
- Goal:

## Stow Packages & Linking
- Packages:
- Outputs/config links:

## Machine-Specific Notes
- Display:
- Network:
- Power:
- GPU/accelerators:
- Services:

## Validation Notes
- What to reload/restart after changes:
```

## Build, Test, and Development Commands
This repo is configuration-only; there is no build or automated test suite.
- Apply configs with GNU Stow:
  - `cd ~/.dotfiles`
  - `stow bash sway waybar i3 nvim xkb x11 wallpaper`
- If you add a new package, keep it as a top-level folder and stow it explicitly.

## Coding Style & Naming Conventions
- Follow the existing style in each file (indentation, spacing, and ordering). Avoid sweeping reformatting.
- Name directories after the target tool or platform (`sway-chromebook/`, `xkb-chromebook/`).
- Keep paths relative to the repo and prefer explicit filenames in docs (e.g., `sway/.config/sway/config.d/outputs.conf.desktop`).

## Testing Guidelines
- There are no automated tests. Validate changes manually by applying the relevant stow package(s) and restarting the affected tool (e.g., reload `sway` or `waybar`).

## Commit & Pull Request Guidelines
- Commit subjects are short, imperative sentences (e.g., “Update cb-link aliases and env loading”). Avoid prefixes unless needed.
- PRs should describe the target machine or package, list affected configs, and include verification notes (what you reloaded or tested). Screenshots are only needed for UI changes (sway/waybar).

## Security & Configuration Tips
- Do not commit secrets, tokens, or host-specific credentials. Keep sensitive values in local, untracked files and reference them from configs when possible.
- Prefer reusable, shared configs across machines; add machine-specific overrides only when required.
