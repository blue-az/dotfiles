# Issue Tracking

Hardware and software issues for ROG Flow Z13 (GZ302EA) - 2025 model.

## Open Issues

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
