# Issue Tracking

Hardware and software issues for ROG Flow Z13 (GZ302EA) - 2025 model.

## Open Issues

### File Picker Dialogs Not Working in Sway
- **Status:** Testing fix
- **Submitted:** 2025-12-16

#### Problem
GTK file picker dialogs don't appear in applications (e.g., Obsidian "Open folder as vault"). This affects any app that uses xdg-desktop-portal for file dialogs.

#### Cause
`xdg-desktop-portal-gtk` service fails with `cannot open display:` because Sway wasn't exporting `WAYLAND_DISPLAY` to systemd user services.

#### Fix Applied
Added to `~/.config/sway/config` in STARTUP section:
```
exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```

#### Testing
- Manual fix worked (portal started successfully after env import)
- Sway reload doesn't apply `exec` commands - requires logout/login or reboot
- Waiting for reboot to confirm permanent fix

#### Notes
- Packages installed: xdg-desktop-portal, xdg-desktop-portal-gtk, xdg-desktop-portal-wlr
- Portal config at `/usr/share/xdg-desktop-portal/sway-portals.conf` correctly routes FileChooser to gtk

## Resolved Issues

### Keyboard Backlight Not Working
- **Status:** Resolved (workaround)
- **Submitted:** 2025-12-05
- **Resolved:** 2025-12-10
- **Issue URL:** https://github.com/NeroReflex/asusctl/issues/101

#### Problem
Keyboard backlight doesn't turn on after cold boot to Linux. sysfs brightness writes succeed but produce no light.

#### Solution/Workaround
Boot into Windows first, then reboot into Linux. The keyboard backlight state persists in firmware/EC across reboots. On Linux boot, asusd eventually initializes and the backlight works.

**Observed behavior (2025-12-10):**
1. Booted Windows - keyboard dark initially
2. After Windows restart - keyboard lit up
3. Rebooted into Linux - keyboard lit during boot, briefly blocked typing (~30s), then worked normally
4. `asusctl -k low/med/high` now controls brightness

#### Device Info
- Model: ASUS ROG Flow Z13 (GZ302EA) - 2025 model
- OS: Fedora 43, kernel 6.17.9
- asusctl: 6.1.12

#### Logs
asusd shows model not in database but uses defaults:
```
[WARN] the aura_support.ron file has no entry for this model: GZ302EA, 18c6. Using a default
[INFO] Found keyboard LED controls at "asus::kbd_backlight"
```

#### Notes
- Windows/Armoury Crate initializes the keyboard LED controller in firmware
- Linux asusd can then read/write via `/sys/class/leds/asus::kbd_backlight/brightness`
- The ~30s input block on boot may be asusd probing the HID devices
- Cold boot directly to Linux still doesn't work - needs Windows boot first

#### Update 2025-12-10
Direct Linux boot now works - backlight visible without Windows boot first. Survived reboot.
- Never manually ran Armoury Crate - likely auto-installed/updated via Windows Update
- Windows background services may have updated EC firmware or LED defaults
- Testing full shutdown next to confirm fix is permanent
