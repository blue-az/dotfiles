# Mac Mini Setup

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
