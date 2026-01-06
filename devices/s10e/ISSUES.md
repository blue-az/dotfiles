# Samsung Galaxy S10e (SM-G970F) Issues

## Goal
Install LineageOS to solve data/data access issues.

## Status: RESOLVED (2026-01-02)

LineageOS 21 successfully installed with Magisk 30.6 true root.
Full /data/data/ access achieved. Root-requiring apps (Total Commander, etc.) work.

## Device Info
- Model: SM-G970F (Exynos, beyond0lte)
- Original firmware: G970FXXSGHWC1 (Android 12, OneUI 4)
- Bootloader: UNLOCKED
- Current OS: LineageOS 21 (Android 14)

## Working Setup

### Files Required
- `lineage-21.0-20240626-recovery-Linux4-beyond0lte.img` - from https://lineage.linux4.de
- `lineage-21.0-20240626-UNOFFICIAL-Linux4-beyond0lte.zip` - from https://lineage.linux4.de
- `vbmeta_disabled.img` - AVB bypass
- `MindTheGapps-14.0.0-arm64-*.zip` - for Google Play Store

### Installation Steps

1. **Create recovery tar:**
   ```bash
   tar -cvf lineage_recovery_vbmeta.tar recovery.img vbmeta.img
   ```

2. **Flash stock first** (warms up Odin, makes subsequent flashes more reliable)
   - Complete initial setup INCLUDING WiFi connection (may be relevant)

3. **Enter download mode via ADB:**
   ```bash
   adb reboot download
   ```
   **Critical:** Use ADB method, not button combo. Button combo causes RQT_CLOSE errors.

4. **Flash recovery via Odin:**
   - AP slot → lineage_recovery_vbmeta.tar
   - Options → Uncheck "Auto Reboot"
   - Start → Wait for PASS

5. **Boot to recovery immediately:**
   - Vol Down + Power (force off)
   - Vol Up + Bixby + Power (boot to recovery)
   - DO NOT let it boot to system first

6. **In LineageOS Recovery:**
   - Factory reset
   - Apply update → Apply from ADB
   - `adb sideload lineage-21.0-*.zip`
   - Reboot

7. **Install GApps (optional, after first boot):**
   - `adb reboot recovery`
   - Apply update → Apply from ADB
   - `adb sideload MindTheGapps-14.0.0-arm64-*.zip`
   - Reboot

### Accessing /data/data/
```bash
adb root
adb shell "ls -la /data/data/"
adb pull /data/data/com.garmin.android.apps.connectmobile/ ./backup/
```

## Key Discovery: Download Mode Entry Matters

**Button combo method:** Power off → Vol Down + Bixby → Plug USB → Vol Up
- Shows warning screen, requires confirmation
- Odin flashes have FAILED with RQT_CLOSE

**ADB method:** `adb reboot download`
- Goes directly to download mode, no warning screen
- Different screen appearance
- Odin flashes SUCCEED using this method

**Always use `adb reboot download` for flashing via Odin.**

## What Didn't Work

- Heimdall - reports success but doesn't persist writes
- LineageOS 18.1 - boot loop on Android 12 firmware (version mismatch)
- LineageOS 23 - TWRP can't flash ("current recovery does not support dynamic partitions")
- Samsung stock recovery - rejects unsigned ROMs (signature verification failed)
- Firmware downgrade - blocked by anti-rollback protection
- TWRP alone - boot loop without vbmeta_disabled
- Magisk root attempts on stock Samsung - all failed with boot loops

## Troubleshooting History: 2026-01-01 Failed Attempts

**Alternative:** Request data export from connect.garmin.com

### Download Mode Count: 12

| # | Time | Purpose | Result |
|---|------|---------|--------|
| 1 | ~17:45 | Initial check | Detected, then timed out |
| 2 | ~17:50 | Flash LineageOS recovery | Upload success, no recovery |
| 3 | ~18:00 | Re-flash recovery + vbmeta | Upload success, stock recovery |
| 4 | ~18:08 | Flash with --no-reboot | Upload success, stock recovery |
| 5 | ~18:25 | Flash TWRP | Upload success, no recovery |
| 6 | ~18:30 | Flash TWRP + vbmeta_disabled | Upload success, "backup failed" msg |
| 7 | ~18:35 | Check PIT (dropped) | Connection lost |
| 8 | ~18:38 | Flash TWRP without --no-reboot | Upload success, stock recovery |
| 9 | ~18:45 | PIT dump | Success |
| 10 | ~19:05 | Full boot chain (boot/dtb/dtbo/recovery/vbmeta) | Upload success, "PDP backup" error, stock recovery |
| 11 | ~19:40 | Stock boot + stock vbmeta_disabled + TWRP | **BRICK** - Blue error screen, stuck in boot loop |
| 12 | ~19:50 | Stock boot + stock vbmeta (recovery) | Success - phone recovered |

### ⚠️ WARNING: vbmeta_disabled WILL BRICK
Flashing `vbmeta_disabled` (byte 123 = 0x02) caused an unrecoverable boot loop:
- Blue screen: "error occurred while updating software"
- Phone stuck in loop, could not exit to download mode
- Power button combo did not work
- Only recovered by catching download mode during brief reset window
- **DO NOT USE vbmeta_disabled on this firmware**

### Issue
Recovery partition flashes report success but stock Samsung recovery persists.
"PDP backup" error flashes briefly before welcome screen.
Factory reset + cache wipe from stock recovery did not help.

### Current State (2026-01-01 ~20:15)
**RECOVERED** - Phone boots to Samsung recovery. Stock boot + stock vbmeta.

### Analysis
- vbmeta_disabled (patched byte 123) causes blue error screen / boot loop
- Stock vbmeta boots fine
- **Heimdall does not work** - reports "success" but writes don't persist
- Custom recovery (TWRP/LineageOS) flashes "succeed" but Samsung recovery always loads
- Original TWRP install used **Odin on Windows**, not Heimdall
- Must use Odin for any future flash attempts

## Magisk (After LineageOS)

Once LineageOS is running, Magisk installs easily:

1. `adb root`
2. `adb shell "dd if=/dev/block/sda14 of=/sdcard/boot_lineage.img"`
3. `adb pull /sdcard/boot_lineage.img`
4. `adb install Magisk-v30.6.apk`
5. Open Magisk → Install → Select and Patch a File → `/sdcard/boot_lineage.img`
6. Magisk patches and flashes directly (Direct Install via ADB root)
7. Reboot

**Key insight:** Magisk failed on stock Samsung due to AVB (Android Verified Boot).
LineageOS has vbmeta disabled, so Magisk works without fighting the bootloader.

## Sources

- LineageOS 21 unofficial: https://lineage.linux4.de
- XDA thread (confirmed working on same firmware): https://xdaforums.com/t/rom-unofficial-14-lineageos-21-for-galaxy-s10e-s10-s10-s10-5g-exynos.4640910/
- MindTheGapps: https://github.com/MindTheGapps/14.0.0-arm64/releases
