# Issue Tracking

Hardware and software issues for ROG Flow Z13 (GZ302EA) - 2025 model.

## Open Issues

### Keyboard Backlight Not Working
- **Status:** Open
- **Submitted:** 2025-12-05
- **Issue URL:** https://github.com/NeroReflex/asusctl/issues/101

#### Problem
Keyboard backlight doesn't turn on. sysfs brightness writes succeed but produce no light.

#### Device Info
- Model: ASUS ROG Flow Z13 (GZ302EA) - 2025 model
- OS: Fedora 43, kernel 6.17.9
- asusctl: 6.1.12

#### USB Devices
- `0b05:1a30` - GZ302EA-Keyboard
- `0b05:18c6` - N-KEY Device

#### Logs
asusd shows:
```
[WARN] the aura_support.ron file has no entry for this model: GZ302EA, 18c6. Using a default
[INFO] Unknown or invalid laptop aura: "1a30", skipping
```

Kernel dmesg shows probe failures:
```
asus 0003:0B05:1A30.0002: probe with driver asus failed with error -12
asus 0003:0B05:18C6.0009: probe with driver asus failed with error -12
```

#### What Was Tried
- `asusctl -k high` - no effect
- `asusctl aura static -c ff0000` - no effect
- `echo 3 > /sys/class/leds/asus::kbd_backlight/brightness` - value accepted, no light
- `echo 3 > /sys/class/leds/asus::kbd_backlight_1/brightness` - value accepted, no light
- Direct HID writes to hidraw0/hidraw3 with `[0x5a, 0xba, 0xc5, 0xc4, 0x03]` - no effect

#### Notes
- Keyboard backlight may have worked on Bazzite (possibly red color), suggesting hardware is functional
- The `-12` error is `ENOMEM` - kernel `hid_asus` driver failing during probe
- Device IDs `1a30` and `18c6` not in asusctl's `aura_support.ron` database

---

## Resolved Issues

(none yet)
