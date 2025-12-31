# Galaxy Note 8.0 (GT-N5110) Issues

## Open Issues

### Device Freezes When Enabling ADB Root
- **Status:** Open
- **Submitted:** 2025-12-31

#### Problem
Device freezes when using LineageOS "Root access: ADB only" developer option and running `adb root`.

#### Symptoms
- Tablet becomes unresponsive after `adb root` command
- Device disconnects from ADB and doesn't reconnect
- Happened twice in a row
- Eventually unfreezes on its own (no reboot required)
- Once unfrozen, ADB root works correctly (uid=0, /data/data accessible)

#### Environment
- ROM: LineageOS 14.1 (userdebug build)
- Android: 7.1.2
- Build: lineage_n5110-userdebug NJH47F e90ff12dc9

#### To Investigate
- Check if issue is specific to this LineageOS build
- Try with different USB cable/port
- Check dmesg/logcat for errors before freeze
- May be a known issue with this device's LineageOS build

## Resolved Issues

(none yet)
