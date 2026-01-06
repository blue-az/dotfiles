# Root Ideas

Brainstormed 2026-01-02 after successfully rooting S10e with LineageOS 21 + Magisk.

## Current Setup

| Device | OS | Root |
|--------|-----|------|
| S10e (SM-G970F) | LineageOS 21 (Android 14) | Magisk 30.6 |
| Avant | Android 5 | Rooted |
| Tablet | Android | Semi-rooted |

## Ideas

### 1. Cross-Device Sync

With root on multiple devices, could set up:
- Syncthing with root access to `/data/data/`
- Automated backups of app data across devices
- Push configs/data between devices
- Unified backup strategy

**Effort:** Low to experiment
**Value:** Potentially high

### 2. LineageOS Customization

Root helps with:
- Magisk modules (AdAway, font changes, system-level tweaks)
- Xposed/LSPosed for app-level hooks
- Deep ROM customization requires building from source (different rabbit hole)

**Effort:** Medium (modules) to Very High (custom builds)
**Value:** Depends on needs

### 3. Garmin API Interception

Now possible with true root:
- Frida to hook Garmin Connect app
- Intercept API responses in memory
- Bypass certificate pinning
- Capture session data before it's discarded

**Effort:** Medium-High (learning Frida)
**Value:** Low (TennisAgent workaround already works)
**Status:** Fun to think about, not urgent

### 4. Nothing

Goals are met:
- Original goal (Avant sensor data) solved long ago
- Garmin workaround functional
- S10e now future-proofed with LineageOS + Magisk

Sometimes "done" is the right answer.

## Notes

- LineageOS 22 build from source = weeks of work for marginal gain
- Frida/Xposed now possible on S10e with true root
- The 3-day rooting journey taught a lot about Android boot chain, AVB, Odin quirks
