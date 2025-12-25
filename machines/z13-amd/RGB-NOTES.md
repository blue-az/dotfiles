# ROG Flow Z13 RGB Control

## asusctl (Linux)

Install on Fedora:
```bash
sudo dnf install asusctl
```

### Features
- Keyboard brightness and RGB effects
- Custom charge limits
- Power profiles
- Fan curves
- AniMe matrix displays (on supported models)

### Commands
```bash
# See available commands
asusctl --help

# Check LED zones
asusctl led-mode --help

# List supported modes
asusctl led-mode -l

# Set static color
asusctl led-mode static -c 50fa7b

# Set logo/back panel (if supported)
asusctl led-mode -z logo static -c bd93f9
```

### Config Files
- Main config: `/etc/asusd/`
- Aura profiles: `/usr/share/asusd/`
- Supported models: `/usr/share/asusd/aura_support.ron`

If the Z13 2025 isn't working, try adding it to `aura_support.ron`.

GUI available via `rog-control-center`.

## Back Panel Known Issues

The 2025 Z13 back panel LEDs have reported issues:
- LEDs light up during boot but stay off otherwise
- May be a firmware limitation
- EC reset (hold power 30 seconds) can help
- Some users report it only works on battery power

## Windows Alternatives

- **Armoury Crate**: Limited control, no API
- **Windows Dynamic Lighting**: Settings → Personalization → Dynamic Lighting (reportedly more reliable than Armoury Crate)
- **Fn + F3/F4**: Brightness control

## Dracula Theme Colors

To match komorebi setup:
- Purple: `#bd93f9`
- Green: `#50fa7b`
- Pink: `#ff79c6`
- Background: `#282a36`

## References

- https://gitlab.com/asus-linux/asusctl
- https://wiki.archlinux.org/title/Asusctl
- https://rog-forum.asus.com/t5/rog-flow-series/rog-flow-z13-2025-backlight/td-p/1081032
