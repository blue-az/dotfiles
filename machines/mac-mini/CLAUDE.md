# Mac Mini Setup (macOS Sequoia)

## Dotfiles Repository
```
Git:   https://github.com/blue-az/dotfiles.git
Local: ~/dotfiles
```
```bash
git clone https://github.com/blue-az/dotfiles.git ~/dotfiles
```

> **Note:** macOS uses `~/dotfiles` (no dot) instead of `~/.dotfiles` used on Linux machines.

## Fastfetch
```
blueaz@Mac-mini
---------------
OS: macOS Sequoia 15.7.2 (24G325) x86_64
Host: Mac mini (2018) (1.0)
Kernel: Darwin 24.6.0
Uptime: 2 mins
Packages: 16 (brew), 1 (brew-cask)
Shell: zsh 5.9
Display (Acer Predator XB271HU): 2560x1440 @ 144 Hz native (165 Hz OC capable) in 27" [External]
WM: Quartz Compositor 278.4.7
WM Theme: Multicolor (Dark)
Theme: Aqua
Font: .AppleSystemUIFont [System], Helvetica [User]
Cursor: Fill - Black, Outline - White (32px)
Terminal: 2.0.73
CPU: Intel(R) Core(TM) i7-8700B (12) @ 3.20 GHz
GPU: Intel UHD Graphics 630 [Integrated]
Memory: 5.05 GiB / 8.00 GiB (63%)
Swap: Disabled
Disk (/): 83.34 GiB / 465.63 GiB (18%) - apfs [Read-only]
Local IP (en1): 192.168.x.x/24
Locale: en_US.UTF-8
```

## Hardware
- Mac mini (2018)
- Intel Core i7-8700B @ 3.20GHz (12 threads)
- Intel UHD Graphics 630
- 8GB RAM
- 500GB SSD
- External display: Acer Predator XB271HU (2560x1440 @ 144Hz native, 165Hz OC capable)

## OS
- macOS Sequoia 15.7.2

This Mac mini is configured to behave similarly to the Fedora desktop/laptop and Debian laptop. Dotfiles are managed via stow in the `blue-az/dotfiles` repo under the `macos/` directory.

## Shell

- **zsh** with vi mode (`bindkey -v`)
- Config: `~/.zshrc`
- nvim as default editor
- fzf integration (Ctrl+R for history, Ctrl+T for files)

## Neovim

- Config: `~/.config/nvim/init.lua`
- Plugin manager: vim-plug
- Plugins: NERDTree (F2), fzf, airline, ALE, vim-surround, easymotion
- Python dev setup with IPython cell support
- `jk` to escape insert mode

## Window Management (yabai + skhd)

Tiling window manager similar to sway/i3 on Linux.

- **yabai**: `~/.yabairc` - tiling WM with focus-follows-mouse
- **skhd**: `~/.skhdrc` - keybindings

### Key Bindings (Caps Lock = mod key)

| Binding | Action |
|---------|--------|
| `Caps + hjkl` | Focus window |
| `Caps + Shift + hjkl` | Move/swap window |
| `Caps + Ctrl + hjkl` | Resize window |
| `Caps + 1-5` | Switch to space |
| `Caps + Shift + 1-5` | Move window to space |
| `Caps + f` | Toggle fullscreen |
| `Caps + Shift + Space` | Toggle float |
| `Caps + Return` | Open terminal |
| `Caps + Shift + q` | Close window |
| `Caps + Shift + r` | Restart yabai |

### Services

```bash
yabai --start-service    # start
yabai --stop-service     # stop
yabai --restart-service  # restart (same for skhd)
```

Logs: `/tmp/yabai_blueaz.[out|err].log`, `/tmp/skhd_blueaz.[out|err].log`

## Keyboard Remapping

Caps Lock and Cmd keys are swapped (like xkb config on Linux):
- **Caps Lock** → Cmd (Super)
- **Left/Right Cmd** → Caps Lock

Persisted via LaunchAgent: `~/Library/LaunchAgents/com.local.KeyRemapping.plist`

## Aliases

| Alias | Command |
|-------|---------|
| `ll` | `ls -halF` |
| `la` | `ls -A` |
| `cl` | `claude` |
| `ff` | `fastfetch` |
| `ffp` | `fastfetch` with IP addresses redacted |
| `jn` | `jupyter notebook` |
| `sbash` / `szsh` | `source ~/.zshrc` |

## Deploying on Fresh Mac

```bash
# Clone dotfiles
git clone https://github.com/blue-az/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install tools
brew install neovim fzf stow
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd

# Deploy configs
stow macos

# Setup fzf
$(brew --prefix)/opt/fzf/install

# Install nvim plugins
nvim --headless +PlugInstall +qall

# Grant accessibility permissions to yabai and skhd in:
# System Settings → Privacy & Security → Accessibility

# Start services
yabai --start-service
skhd --start-service
```
