# Samsung Galaxy S10e (SM-G970F) Issues

## Boot Loop After Firmware Flash

**Status:** Unresolved
**Date:** 2025-12-30

### Symptoms
- Phone stuck at boot screen with spinning dots
- Occurs after full firmware flash
- Vol Up + Bixby + Power (recovery mode) also goes to spinning dots
- Download mode (Vol Down + Bixby + Power) still works

### Firmware Used
- **Source:** SAMFW.COM
- **File:** `SAMFW.COM_SM-G970F_XTC_G970FXXSGHWC1_fac.zip`
- **Version:** G970FXXSGHWC1 (Android 12)
- **Region:** XTC/OXM

### Flash Attempts

#### Attempt 1: Odin (z13-windows)
- Flashed via Odin on Windows
- Same result - boot loop

#### Attempt 2: Heimdall (desktop Linux)
- Heimdall v2.2.2 on Fedora 43
- Extracted firmware: AP, BL, CP, HOME_CSC
- Decompressed all .lz4 files
- Downloaded PIT from device
- Flashed partitions:
  - BOOTLOADER (sboot.bin)
  - CM, PARAM, UP_PARAM, KEYSTORAGE, UH
  - DTB, DTBO, BOOT, RECOVERY
  - RADIO, CP_DEBUG, DQMDBG, VBMETA
  - SYSTEM, VENDOR, PRODUCT, CACHE, USERDATA
- All uploads reported successful
- Phone rebooted to same boot loop

### Not Yet Tried
- [ ] Flash with vbmeta verification disabled
- [ ] Different firmware version
- [ ] Downgrade to Android 10/11 first
- [ ] Check for hardware issues (eMMC/UFS corruption)

### Files Location
- Firmware extracted to: `~/Downloads/s10e_firmware/`
- PIT file: `~/Downloads/s10e_firmware/s10e.pit`

### Notes
- Stock recovery also fails to boot (spinning dots)
- TWRP does not work on this device
- Phone was already wiped/corrupted before flash attempts
