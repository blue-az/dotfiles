# Chromebook Lenovo Guidelines

## Agent Terminology
- **BN = Bottlenecks**: In user prompts and docs, **BN** stands for **Bottlenecks** (friction points and issue tracking).

## Machine Overview
- Host: `penguin` (Lenovo Chromebook in Crostini container)
- OS: Debian GNU/Linux 12 (bookworm) x86_64
- Goal: Lightweight Linux terminal workspace inside ChromeOS container environment.

## Stow Packages & Linking
- Packages: `bash`, `nvim`, `waybar-chromebook` (if applicable)
- Command: `cd ~/.dotfiles && stow bash nvim`

## Machine-Specific Notes
- Display: 3072x1728 @ 2x scaling (managed by ChromeOS)
- WM: None (Crostini container, relies on ChromeOS window management)
- Software: Custom Neovim build in `/opt/nvim-linux64/`

## Validation Notes
- Re-source shell config with `source ~/.bashrc`
