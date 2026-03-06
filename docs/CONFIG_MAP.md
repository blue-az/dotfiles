# Dotfiles Config Map

This file is a quick ownership map to keep the setup understandable for both humans and AI agents.

## Layer Ownership
- `sway/`: compositor/window manager behavior (workspaces, keybinds, outputs, startup)
- `waybar/`: status bar modules, module formatting, bar scripts
- `i3/`: X11 i3 session config plus legacy/shared helper scripts still referenced by Sway/Waybar
- `machines/`: host-specific notes and overrides

## Why i3 still appears in Sway/Waybar paths
Current Sway config references one helper under `~/.config/i3/scripts/`:
- `cycle-video-audio.sh`

Helpers moved to shared path:
- `~/.config/shared/scripts/brightness-ddc.sh`
- `~/.config/shared/scripts/cycle-audio-source.sh`

This means `i3` currently acts as both:
- a real i3 config package, and
- a shared script bucket used by non-i3 sessions.

## Active Cross-Links (Current State)
- `sway/.config/sway/config` -> `~/.config/i3/scripts/cycle-video-audio.sh` and `~/.config/shared/scripts/*`
- `waybar/.config/waybar/config` -> `~/.config/shared/scripts/brightness-ddc.sh`
- `waybar/.config/waybar/config*` -> `~/.config/waybar/scripts/*`

## Small-Step Refactor Order
1. Validate moved brightness helper behavior (`$mod+F1/F2`, waybar brightness scroll).
2. Move remaining audio helper (`cycle-video-audio.sh`) to shared path.
3. Repoint Sway references from `~/.config/i3/scripts/...` to shared path.
4. Keep temporary wrappers in i3 path until migration is complete.

This preserves behavior while making ownership obvious.
