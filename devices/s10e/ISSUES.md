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

1. **KernelSU instead of Magisk** - Different root approach for Android 12
2. **Custom ROM with root** - Find Android 12 based ROM with root built-in
3. **Wait for new exploits** - Security research may find new methods
4. **Different phone** - Use a device with better root support

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
