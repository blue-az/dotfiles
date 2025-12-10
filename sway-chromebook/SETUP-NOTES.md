# Sway Setup Notes for Chromebook (Debian 12 / LightDM)

## Fix: "Unable to create backend" error

If Sway fails to start with "Unable to create backend" error, LightDM may not be properly setting up seat access for Wayland sessions.

### Solution: Install and enable seatd

```bash
sudo apt install seatd
sudo systemctl enable seatd
sudo systemctl start seatd
```

seatd runs with `-g video` by default on Debian, so ensure your user is in the video group:

```bash
sudo usermod -aG video $USER
```

Then **log out completely** and log back into Sway.

### Why this happens

- LightDM was designed primarily for X11
- Wayland compositors need direct access to DRM/GPU devices
- libseat (used by sway/wlroots) needs a seat manager to grant this access
- seatd provides this functionality and works well with LightDM

### Verifying seatd is running

```bash
systemctl status seatd
```

Should show: `seatd -g video` running.

---

## Troubleshooting Session: Dec 5, 2025

### Issue: Sway shows cursor in top-left, won't start

**Symptom:** Black screen with cursor, Sway hangs

### Error 1: X11 backend (DISPLAY variable)

```
Failed to query DRI3 DRM FD
Unable to create backend
```

**Cause:** `export DISPLAY=:0` was set in `~/.bashrc` (line 133), forcing Sway to use X11 backend instead of native DRM.

**Fix:** Commented out the line in `~/.bashrc`:
```bash
# export DISPLAY=:0  # Commented out - breaks Sway (forces X11 backend)
```

### Error 2: DRM permission denied (concurrent session)

```
drmAuthMagic failed: Permission denied
Failed to create allocator
```

**Cause:** Another graphical session (KDE/XFCE) is holding DRM master, preventing Sway from accessing the GPU.

**Fix:** Must fully log out of the other session before starting Sway. Cannot run two compositors on the same seat simultaneously.

```bash
# To kill another session:
loginctl terminate-session <session-id>
# Then start sway
~/startsway.sh
```

### Helper script created: ~/startsway.sh

```bash
#!/bin/bash
unset DISPLAY
exec sway 2>/tmp/sway-error.log
```

---

## Update: TTY Login Auto-Start Sway (Dec 5, 2025)

### Issue: `.bash_profile` was configured to start X11

The original `.bash_profile` had:
```bash
if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    startx
fi
```

This tried to start X11 instead of Sway when logging in from TTY1.

### Fix: Updated `~/.bash_profile` to start Sway

```bash
# Start Sway at login on tty1
if [[ -z $DISPLAY ]] && [[ -z $WAYLAND_DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    export XDG_SESSION_TYPE=wayland
    exec sway
fi
```

**Changes:**
- Replaced `startx` with `exec sway`
- Added `$WAYLAND_DISPLAY` check to prevent double-starting if already in Wayland
- Set `XDG_SESSION_TYPE=wayland` environment variable

### To test:
1. Switch to tty1: `Ctrl+Alt+F1`
2. Login with username/password
3. Sway should auto-start
