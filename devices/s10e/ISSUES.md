# Samsung Galaxy S10e (SM-G970F) Issues

## Boot Loop & Rooting Attempts

**Status:** Partially Resolved - Phone works unrooted, root not achieved
**Date:** 2025-12-30/31

### Device Info
- Model: SM-G970F (Exynos International)
- Codename: beyond0lte
- Firmware: G970FXXSGHWC1 (Android 12, OneUI 4)
- Bootloader: UNLOCKED

### Firmware Used
- **Source:** SAMFW.COM
- **File:** `SAMFW.COM_SM-G970F_XTC_G970FXXSGHWC1_fac.zip`
- **Contains:** AP, BL, CP, CSC, HOME_CSC

### Files Location
- Firmware extracted: `~/Downloads/s10e_firmware/`
- PIT file: `~/Downloads/s10e_firmware/s10e.pit`
- Stock boot: `~/Downloads/s10e_firmware/boot.img`
- Patched boot: `~/Downloads/s10e_firmware/magisk_patched-30600_0oFDr.img`
- vbmeta disabled: `~/Downloads/s10e_firmware/vbmeta_disabled.img`
- TWRP: `~/Downloads/twrp-beyond0lte.img`

---

## What We Learned

### Boot Loop Fix (Temporary)
- **vbmeta_disabled.img** initially fixed boot loops
- Created by patching byte 123 to 0x02: `printf '\x02' | dd of=vbmeta_disabled.img bs=1 seek=123 count=1 conv=notrunc`
- Allowed phone to boot to factory reset screen
- Allowed TWRP to boot (previously boot looped)

### Root Attempts - ALL FAILED
Despite vbmeta disabled allowing boot:
1. **Patched boot via Heimdall** - Phone boots, but Magisk shows N/A, `su` not found
2. **TWRP + Magisk.zip sideload** - Same result, no root
3. **TWRP + multidisabler + Magisk** - Same result
4. **Boot to TWRP first after flash** (per XDA guide) - Same result
5. **Older Magisk v25.2** - Couldn't test, storage broke

### Storage Corruption Issue
- TWRP "Format Data" corrupted filesystem
- Showed as -100GB/8GB in TWRP
- "Resize File System" didn't fix it
- "Change File System to Ext4" didn't fix it
- Only full firmware flash restored storage

### vbmeta Inconsistency
- vbmeta_disabled worked initially (phone booted)
- After TWRP/rooting attempts, vbmeta_disabled caused boot loops
- Stock vbmeta now boots fine
- Unclear why behavior changed

---

## Current State
- Phone boots with **stock vbmeta**
- Storage working (~110GB)
- **NOT rooted** - stock firmware
- TWRP installed to recovery partition (accessible via Vol Up + Bixby + Power)

---

## What Was Tried (Chronological)

### z13-windows (Odin)
1. Patched boot.img via Heimdall - boot loop
2. Pre-patched AP tar - boots but no root
3. Magisk-patched boot as tar - boot loop
4. TWRP recovery - boot loop
5. Repack full AP with patched boot - boot loop

### Desktop (Heimdall)
1. Full firmware flash - boot loop
2. Flash vbmeta_disabled - **FIXED boot loop**
3. Flash vbmeta_disabled + patched boot - boots, no root
4. Flash TWRP to recovery - works with vbmeta disabled
5. Sideload multidisabler + Magisk via TWRP - no root
6. Format Data in TWRP - corrupted storage
7. Full firmware reflash - boot loop returned
8. Stock vbmeta - boots fine

---

## Android 9 Downgrade - BLOCKED

**Attempted:** 2025-12-31
**Firmware:** `SAMFW.COM_SM-G970F_XTC_G970FXXS3ASJG_fac.zip` (Android 9 Pie)
**Result:** FAILED - Anti-rollback protection

Samsung's bootloader anti-rollback prevents downgrading once updated. Phone shows "unsupported version" when attempting to flash Android 9 bootloader on a device that has Android 12 bootloader.

**This is a hard block** - no workaround without hardware modification.

---

## Remaining Options

### 1. LineageOS 23.0 (Recommended)
**Official LineageOS support exists for SM-G970F (beyond0lte)**

- **Android version:** 16 (exceeds Garmin Connect's Android 9 requirement)
- **Prerequisites you have:**
  - Unlocked bootloader ✅
  - Android 12 firmware ✅
  - Heimdall experience ✅

**Why this might work when stock didn't:**
- No Knox fighting Magisk
- Cleaner boot chain without Samsung bloat
- Community-tested root procedures

**Installation:**
1. Download LineageOS from https://download.lineageos.org/devices/beyond0lte
2. Flash Lineage Recovery via Heimdall (not TWRP)
3. Sideload LineageOS ZIP via ADB
4. Flash Magisk after LineageOS is working
5. Should get real root (not just ADB root)

**Resources:**
- https://wiki.lineageos.org/devices/beyond0lte/
- https://wiki.lineageos.org/devices/beyond0lte/install/

### 2. KernelSU instead of Magisk
Different root approach for Android 12 - untested on this device

### 3. Wait for new exploits
Security research may find new methods

### 4. Different phone
Use a device with better root support

---

## Key Commands

### Download Mode
```
Vol Down + Bixby + USB plug → Vol Up to continue
```

### Recovery Mode (TWRP)
```
Vol Up + Bixby + Power (hold while powering on)
```

### Full Firmware Flash (Heimdall)
```bash
cd ~/Downloads/s10e_firmware
heimdall flash \
  --BOOTLOADER sboot.bin \
  --CM cm.bin \
  --PARAM param.bin \
  --UP_PARAM up_param.bin \
  --KEYSTORAGE keystorage.bin \
  --UH uh.bin \
  --DTB dt.img \
  --DTBO dtbo.img \
  --BOOT boot.img \
  --RECOVERY recovery.img \
  --RADIO modem.bin \
  --CP_DEBUG modem_debug.bin \
  --DQMDBG dqmdbg.img \
  --VBMETA vbmeta.img \
  --SYSTEM system.img \
  --VENDOR vendor.img \
  --PRODUCT product.img \
  --CACHE cache.img \
  --USERDATA userdata.img
```

### Create vbmeta_disabled
```bash
cp vbmeta.img vbmeta_disabled.img
printf '\x02' | dd of=vbmeta_disabled.img bs=1 seek=123 count=1 conv=notrunc
```

---

## Use Case Status

**Goal:** Root phone for direct Garmin data transfer (Watch → Phone → PC)

**Result:** Not achieved. Without root, Garmin Connect just syncs to cloud - no advantage over iPhone or web export.

**Alternative:** Request data export from connect.garmin.com

---

## LineageOS Installation Attempt - 2026-01-01

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

### Next Steps
1. Boot to Windows
2. Use Odin to flash TWRP (wrap in .tar, flash to AP slot)
3. If TWRP works, sideload LineageOS
4. Do NOT touch vbmeta
