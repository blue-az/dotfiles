# Samsung Galaxy S10e (SM-G970F)

## Device Info

| Property | Value |
|----------|-------|
| Model | SM-G970F |
| Codename | beyond0lte |
| Variant | Exynos 9820 |
| Storage | 128GB |
| Bootloader | UNLOCKED |

## Current State

| Property | Value |
|----------|-------|
| OS | LineageOS 21 (Android 14) |
| Build | lineage-21.0-20240626-UNOFFICIAL-Linux4 |
| Recovery | LineageOS Recovery |
| Root | Magisk 30.6 (true root) |
| GApps | MindTheGapps 14.0.0 |

## History

| Date | Firmware | Notes |
|------|----------|-------|
| Original | Stock Android 9 | As purchased |
| ~2024 | G970FXXSGHWC1 (Android 12) | Samsung OTA update |
| 2026-01-02 | LineageOS 21 | Custom ROM install |

## Why LineageOS?

Needed /data/data/ access for app data extraction. On Android 12 firmware:
- Magisk root not possible (boot loops on stock Samsung)
- Firmware downgrade blocked (anti-rollback)
- TWRP can't flash modern ROMs (no dynamic partition support)

LineageOS 21 was the only path forward. Once installed, Magisk works easily
(stock Samsung AVB was the problem, not Magisk itself).

## Key Files

Located in `C:\Users\efehn\OneDrive\Desktop\10e root\`:
- `lineage_recovery_vbmeta.tar` - Recovery + vbmeta for Odin
- `lineage-21.0-20240626-UNOFFICIAL-Linux4-beyond0lte.zip` - ROM
- `vbmeta_disabled.img` - AVB bypass

## Useful Commands

```bash
# Check connection
adb devices

# Root shell
adb root
adb shell

# Access app data
adb shell "ls -la /data/data/"

# Pull app data (use PowerShell or CMD, not Git Bash - it mangles /data paths)
adb pull /data/data/com.garmin.android.apps.connectmobile/ ./garmin_backup/

# Reboot to recovery
adb reboot recovery

# Reboot to download mode (for Odin)
adb reboot download
```

## Pulling App Data (Important)

Git Bash mangles paths starting with `/`, converting them to Windows paths.

**Use PowerShell or CMD instead:**
```powershell
adb root
adb pull /data/data/com.garmin.android.apps.connectmobile/ .\garmin_backup\
```

**Or from Linux:**
```bash
adb root
adb pull /data/data/com.garmin.android.apps.connectmobile/ ./garmin_backup/
```

## Recovery Instructions

If you need to reflash LineageOS:

1. `adb reboot download` (NOT button combo - causes RQT_CLOSE errors)
2. Odin → AP → `lineage_recovery_vbmeta.tar`
3. Boot to recovery: Vol Up + Bixby + Power
4. Factory reset
5. Apply update → ADB sideload
6. `adb sideload lineage-21.0-*.zip`

See [ISSUES.md](ISSUES.md) for full installation guide.

## Magisk Installation (After LineageOS)

Once LineageOS is stable, Magisk installs easily:

```bash
# Pull current boot image
adb root
adb shell "dd if=/dev/block/sda14 of=/sdcard/boot_lineage.img"
adb pull /sdcard/boot_lineage.img

# Install Magisk app
adb install Magisk-v30.6.apk
```

Then on phone:
1. Open Magisk → Install → Select and Patch a File
2. Select `/sdcard/boot_lineage.img`
3. Magisk uses Direct Install (ADB root allows writing to boot partition)
4. Reboot - done

**Why it works now:** LineageOS has vbmeta disabled and no AVB fighting you.
Stock Samsung Android 12 firmware blocked every Magisk attempt with boot loops.

## Links

- LineageOS builds: https://lineage.linux4.de
- XDA thread: https://xdaforums.com/t/rom-unofficial-14-lineageos-21-for-galaxy-s10e-s10-s10-s10-5g-exynos.4640910/
- MindTheGapps: https://github.com/MindTheGapps/14.0.0-arm64/releases
