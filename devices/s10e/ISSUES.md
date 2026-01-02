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
