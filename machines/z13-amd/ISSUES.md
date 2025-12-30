# Z13 AMD Issue Tracking

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

### Ollama Falls Back to CPU (gfx1151 Not Used)
- **Status:** Open - upstream issue filed
- **Submitted:** 2025-12-30
- **Issue URL:** https://github.com/ollama/ollama/issues/13589

#### Problem
Ollama silently falls back to CPU inference on Linux even though `rocminfo` correctly detects the gfx1151 GPU. The same hardware works with GPU on Windows.

```
$ ollama ps
NAME               ID              SIZE      PROCESSOR
granite4:latest    4235724a127c    2.4 GB    100% CPU
```

#### Environment
- ROCm 6.4.2 installed and detecting GPU correctly
- Kernel 6.17.12-300.fc43.x86_64
- Device permissions OK (/dev/kfd, /dev/dri/renderD128 world-accessible)

#### What's Been Tried
1. Built Ollama from main (post PR #13196 GTT fix) - still CPU
2. HSA_OVERRIDE_GFX_VERSION=11.5.0 - still CPU
3. Verified rocminfo shows gfx1151 as Agent 2 with KERNEL_DISPATCH

#### Related Issues
- #9553 - gfx1151 crashes on Windows
- #10993 - gfx1151 crashes on Windows
- #12062 - GTT memory fix (merged Dec 23, didn't help)

#### Notes
- Windows dual-boot uses GPU successfully
- No error messages - just silent fallback to CPU
- gfx1151 is listed as "supported" in Ollama docs
- Waiting for upstream fix

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
