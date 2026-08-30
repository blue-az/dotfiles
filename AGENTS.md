# Repository Guidelines

## Agent Terminology & Definitions
- **BN = Bottlenecks**: In user prompts and documentation, **BN** stands for **Bottlenecks** (tracking system/workflow friction points, issue tracking, and bottleneck resolution). Always interpret "BN" as Bottlenecks.

## Project Structure & Module Organization
- Top-level folders are stow packages for dotfiles (e.g., `apps/`, `audio/`, `bash/`, `nvim/`, `sway/`, `waybar/`, `xkb/`, `wallpaper/`, `x11/`, `macos/`). Each package mirrors the target path under `$HOME` (for example `sway/.config/sway/`).
- Hardware- and OS-specific notes live in `machines/` (per host) and `devices/` (phones/tablets). Monitor presets are in `monitors/`.
- `tests/` is **not** a stow package -- never `stow tests`, or its contents land in `$HOME`. It holds the audio-cycler suite and its `pactl` fixtures, and is run from the repo root.
- Issues and setup references are documented in `ISSUES.md` and the various `CLAUDE.md` or `README.md` files.
## Machine-Specific Guides
- Comprehensive machine sitemap and specs: [machine-overview.md](file:///home/blueaz/.dotfiles/machines/machine-overview.md).
- Hardware parts inventory (built systems + spare-parts shelf): `machines/parts/README.md`.
- Host-level contributor notes live in `machines/<name>/AGENTS.md`. Use these for per-machine stow sets, output configs, and device-specific quirks.
- Key Linux Guides: `machines/desktop/AGENTS.md`, `machines/z13-amd/AGENTS.md`, `machines/pine-phone/AGENTS.md`, `machines/raspberrypi/AGENTS.md`.
- macOS & Chromebook Guides: `machines/mac-mini/AGENTS.md`, `machines/chromebook-lenovo/AGENTS.md`, `machines/chromebook-kevin/AGENTS.md`, `machines/ideapad-u400/AGENTS.md`.
- Windows Guides: `machines/desktop-windows/AGENTS.md`, `machines/z13-windows/AGENTS.md`.
## Current Machine (Agent Note)
- To identify the host, run: `hostnamectl --static` (preferred) or `cat /etc/hostname`.
- Map the hostname to its `machines/` directory before opening or creating anything — hostnames and directory names are not 1:1:
  - `z13` (formerly `fedora`), aka "laptop" or "AMD" → `machines/z13-amd/`
  - `desktop`, aka "3090" → `machines/desktop/`
- Only create a new `machines/<name>/` directory for genuinely new hardware, never for a renamed or aliased host. Do not create a literal-hostname directory (e.g., `machines/fedora/`) for a machine already listed above.
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
This repo is configuration-only and has no build step. It carries one small test
suite, in `tests/`, covering the audio-output cycler; everything else is validated
by hand.
- Apply configs with GNU Stow:
  - `cd ~/.dotfiles`
  - `stow apps bash sway waybar i3 nvim xkb x11 wallpaper`
- If you add a new package, keep it as a top-level folder and stow it explicitly.

## Coding Style & Naming Conventions
- Follow the existing style in each file (indentation, spacing, and ordering). Avoid sweeping reformatting.
- Name directories after the target tool or platform (`sway-chromebook/`, `xkb-chromebook/`).
- Keep paths relative to the repo and prefer explicit filenames in docs (e.g., `sway/.config/sway/config.d/outputs.conf.desktop`).

## Testing Guidelines
- Most changes have no automated tests. Validate them manually by applying the relevant stow package(s) and restarting the affected tool (e.g., reload `sway` or `waybar`).
- The exception is the audio-output cycler. `shared/.config/shared/scripts/audio_ports.py` parses `pactl list cards` port presence-detect flags, which is fiddly enough that an earlier ELD-rank implementation paired the two displays backwards. Run `python3 -m pytest tests/ -q` from the repo root after touching either `audio_ports.py` or `audio_cycle.py`.
- Those two modules live under a stow package because they are stowed config: `cycle-audio-output.sh` calls `audio_cycle.py` as a sibling. They previously lived in `operator-control-plane` and were reached via `$OPERATOR_REPO`; that broke the keybinding twice, so do not reintroduce a cross-repo path.

## Commit & Pull Request Guidelines
- Commit subjects are short, imperative sentences (e.g., “Update cb-link aliases and env loading”). Avoid prefixes unless needed.
- PRs should describe the target machine or package, list affected configs, and include verification notes (what you reloaded or tested). Screenshots are only needed for UI changes (sway/waybar).

## Security & Configuration Tips
- Do not commit secrets, tokens, or host-specific credentials. Keep sensitive values in local, untracked files and reference them from configs when possible.
- Prefer reusable, shared configs across machines; add machine-specific overrides only when required.
