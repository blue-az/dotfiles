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

## Window Management (Aerospace)

Tiling window manager — i3 equivalent for macOS. Single TOML config, no separate keybinding daemon.

- **aerospace**: `~/.config/aerospace/aerospace.toml`

### Key Bindings (Caps Lock = mod key)

| Binding | Action |
|---------|--------|
| `Caps + hjkl` | Focus window |
| `Caps + Shift + hjkl` | Move/swap window |
| `Caps + r` | Enter resize mode (then hjkl to resize, Enter/Esc to exit) |
| `Caps + 1-5` | Switch workspace |
| `Caps + Shift + 1-5` | Move window to workspace |
| `Caps + f` | Toggle fullscreen |
| `Caps + Shift + t` | Toggle float |
| `Caps + e` | Cycle split direction |
| `Caps + =` | Balance windows |
| `Caps + Return` | Open terminal |
| `Caps + Shift + q` | Close window |
| `Caps + Shift + r` | Reload config |

### Services

```bash
brew install nikitabobko/tap/aerospace
# Grant accessibility permissions in:
# System Settings → Privacy & Security → Accessibility
aerospace reload-config
```

## Keyboard Remapping

Caps Lock becomes the WM mod key by mapping to **Left Option**, not Command
(`com.local.KeyRemapping.plist`, applied via hidutil):
- **Caps Lock** → Left Option  ← this is the mod key AeroSpace binds (`alt-`)
- **Left Option** → Caps Lock
- **Right Command** → Caps Lock

Left Command is deliberately untouched, so macOS shortcuts (Cmd+F, Cmd+L,
Cmd+1-5) stay free. Binding the WM to `cmd-` instead would swallow them --
that is what made skhd unusable.

Persisted via LaunchAgent: `~/Library/LaunchAgents/com.local.KeyRemapping.plist`

## Aliases

| Alias | Command |
|-------|---------|
| `ll` | `ls -halF` |
| `la` | `ls -A` |
| `cl` | `claude` |
| `UC` | `brew upgrade --cask claude-code` |
| `UG` | `brew upgrade gemini-cli` |
| `PP` | `cd ~/Python/project-phoenix` |
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
brew install nikitabobko/tap/aerospace

# Deploy configs
stow macos

# Setup fzf
$(brew --prefix)/opt/fzf/install

# Install nvim plugins
nvim --headless +PlugInstall +qall

# Grant accessibility permissions to aerospace in:
# System Settings → Privacy & Security → Accessibility

# Start aerospace (or set start-at-login = true in config)
aerospace reload-config
```
