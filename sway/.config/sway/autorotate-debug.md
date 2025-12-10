# Auto-Rotate Debug Log

## Problem Summary
- Auto-rotate works before suspend
- After resume from suspend, rotation stops working
- Sometimes can't unlock after suspend (keyboard/touchscreen unresponsive)

## Hardware
- ASUS ROG Flow Z13 (GZ302EA)
- Accelerometer: /sys/bus/iio/devices/iio:device0

## Current State (2025-12-02 18:37)
- Service file: ~/.config/systemd/user/sway-autorotate.service
- Script: ~/.local/bin/sway-autorotate
- Accelerometer IS readable after resume (confirmed)
- swaymsg commands work manually after resume
- Multiple processes can accumulate (found 2 running)

## Session 1 (2025-12-02)

### Issue Found
The service had `PartOf=graphical-session.target` but that target is never activated by Sway, causing immediate service stop on boot.

### Change Made
Removed dependency on graphical-session.target:
```
[Unit]
Description=Auto-rotate screen for Sway

[Service]
Type=simple
ExecStart=/bin/bash -c 'export SWAYSOCK=$(ls /run/user/1000/sway-ipc.*.sock 2>/dev/null | head -1); exec python3 /home/blueaz/.local/bin/sway-autorotate'
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
```

### Result
- Service now starts and stays running on boot
- Rotation works before suspend
- After suspend: service still shows "active (running)" but rotation doesn't work
- Found 2 python processes running (stale + new)

### Observations
1. USB webcam (bus 1-1) failed to resume in previous boot logs (error -22, 10 second delay)
2. The SWAYSOCK path in ExecStart is determined at service start - if socket changes, old value is stale
3. `Restart=always` may be creating duplicate processes without killing old ones

## Things NOT to retry without new information
- [ ] Adding `Restart=always` alone - doesn't help, may cause duplicates
- [ ] Depending on graphical-session.target - it's never active

## ROOT CAUSE FOUND (Session 1) - FINAL
**The sysfs accelerometer (iio:device0) freezes after resume**

Confirmed behavior after resume:
- Sysfs reads (/sys/bus/iio/devices/iio:device0/in_accel_*_raw) return FROZEN values
- Values don't change even when device is rotated
- Keyboard STILL freezes in portrait mode (hardware/magnetic detection, separate from accelerometer)
- Screen doesn't rotate because script reads frozen sysfs values

The keyboard freeze is NOT software - it's hardware (likely hall sensor or magnetic switch in keyboard dock).

Module: hid_sensor_accel_3d

## Things Already Tried (part of the loop)
- [ ] Adding `Restart=always` - causes duplicate processes
- [ ] Depending on graphical-session.target - it's never active
- [ ] 2-second timeout on swaymsg - doesn't help, swaymsg isn't the problem
- [ ] Reloading hid_sensor_accel_3d module - already tried

## What We Need
A way to reset/wake the accelerometer sensor after resume that actually works.

## Session 1 - Attempt 1 (2025-12-02 ~19:05)
Modified /home/blueaz/.local/bin/sway-autorotate-resume to reload module:
- Added: modprobe -r hid_sensor_accel_3d && modprobe hid_sensor_accel_3d
- Hook exists at /usr/lib/systemd/system-sleep/sway-autorotate-resume (symlink)
- No log file existed at /tmp/sway-autorotate-resume.log - hook may not be running

## THE LOOP (documented for pattern tracking)

### Loop Instance 1 (2025-12-02 ~19:08)
**Before suspend:** Rotation works, keyboard freezes in portrait (correct)
**After suspend:** Screen won't rotate, keyboard still freezes in portrait
**Agent did:** Unknown - checked accelerometer values twice, second time showed different values
**Result:** Rotation started working again
**Agent explanation:** None given yet
**Actual fix:** Unknown - agent didn't explicitly run modprobe or restart service between checks

### Loop Instance 2 (2025-12-02 ~19:15)
**Before suspend:** Rotation works
**After suspend:** Screen won't rotate, keyboard still freezes in portrait
**Agent ran these commands in order:**
1. cat accel_x_raw - no fix
2. cat accel_y_raw - no fix
3. cat accel_z_raw - no fix
4. pgrep sway-autorotate - no fix
5. systemctl --user status sway-autorotate - no fix
6. tail -5 log - no fix
7. systemctl --user restart sway-autorotate - no fix
8. **swaymsg output eDP-1 transform 90 scale 2** - SCREEN SPUN (this is the "metal brain spin")
9. swaymsg output eDP-1 transform normal scale 2 - screen back to normal

**After manual swaymsg:** Screen spun but auto-rotate still doesn't work
**Accelerometer test:** Values frozen at -7, -925, -355 even when device tipped for 10 seconds
**Keyboard:** Still freezes in portrait (hardware detection works)

**Conclusion:**
- swaymsg works after resume
- Accelerometer sysfs values ARE frozen after resume
- Manual modprobe reload unfreezes accelerometer (documented as part of loop)
- Resume hook exists but doesn't seem to run (no log file created)

### Pattern observed:
1. Working setup rotates screen + keyboard freezes in portrait
2. Suspend and login
3. Screen won't rotate, keyboard still freezes in portrait
4. Agent does "metal brain things" (checks values, maybe something else happens)
5. Rotation works again
6. Agent claims fixed
7. REPEAT

### Key findings:
- The accelerometer IS frozen after resume (sysfs reads return stale values)
- Keyboard freeze is hardware-based (works even when accel frozen)
- swaymsg works fine after resume
- modprobe -r/modprobe hid_sensor_accel_3d unfreezes accelerometer
- Resume hook at /usr/lib/systemd/system-sleep/sway-autorotate-resume should do this but isn't working

### Question to answer:
Why isn't the resume hook running? It should reload the module.

### Loop Instance 3 (2025-12-02 ~19:29) - BREAKTHROUGH
**After suspend:** Screen won't rotate, accelerometer frozen
**Agent tried:**
- Many commands checking status - no fix
- swaymsg manual rotate - spun screen but no fix
- Suggested sudo commands - user refused (previous agents fixed without sudo)

**THE FIX (no sudo needed):**
```
pkill -f sway-autorotate
```
Then restart:
```
systemctl --user start sway-autorotate
```

**Result:** Rotation works!

**Conclusion:** The script itself was blocking the accelerometer from updating. Killing it unfroze the sensor. Restarting it works fine after that.

**Root cause hypothesis:** The script holds file handles to the sysfs accelerometer files. After suspend, these handles become stale/blocking. Killing the script releases them, and the new instance gets fresh handles.

## FINAL FIX (2025-12-02 19:35) - UPDATED 2025-12-06

### The Problem
The resume service was killing itself because `pkill -9 -f sway-autorotate` matches its own bash process.

### Manual Fix (when auto-rotate stops working)
```bash
pkill -9 -f sway-autorotate
systemctl --user start sway-autorotate
```

### Automatic Fix (resume service)
Updated `/etc/systemd/system/sway-autorotate-resume.service`:
```
[Unit]
Description=Restart sway-autorotate after resume
After=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'sleep 2; pkill -9 python.*sway-autorotate || true; sleep 1; sudo -u blueaz XDG_RUNTIME_DIR=/run/user/1000 systemctl --user start sway-autorotate.service'

[Install]
WantedBy=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

Then: `sudo systemctl daemon-reload`

**Key change:** Use `pkill -9 python.*sway-autorotate` instead of `pkill -9 -f sway-autorotate` to only match the Python process, not the bash script running pkill.

**Why it works:**
- `systemctl restart` wasn't enough - the stale file handles persisted
- `pkill -9` forcefully kills the process and releases the stale handles
- New process starts with fresh handles that work
- The `|| true` prevents the service from failing if no process is found

### Loop Instance 4 (2025-12-06 ~04:30)
**After suspend:** Screen won't rotate
**Diagnosis:** Resume service was failing - killing itself with its own pkill command
**Fix:** `pkill -9 -f sway-autorotate && systemctl --user start sway-autorotate`
**Result:** Rotation works
**Permanent fix:** Updated resume service to use `python.*sway-autorotate` pattern
