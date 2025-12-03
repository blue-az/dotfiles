# Sway Auto-Rotate Setup for ASUS ROG Flow Z13

## What Works

The final solution reads raw accelerometer values directly from `/sys/bus/iio/devices/iio:device0/` and polls every 0.3 seconds. This bypasses `iio-sensor-proxy` which has buffering issues on this device.

### Files Created

1. **Script**: `~/.local/bin/sway-autorotate`
   - Python script that reads raw accel values from sysfs
   - Calculates orientation based on which axis has gravity
   - Calls `swaymsg output eDP-1 transform <rotation> scale 2`

2. **Systemd Service**: `~/.config/systemd/user/sway-autorotate.service`
   - Runs the script as a user service
   - Must set SWAYSOCK environment variable for swaymsg to work
   - Starts with sway-session.target

### Commands

```bash
# Start/stop/restart
systemctl --user start sway-autorotate
systemctl --user stop sway-autorotate
systemctl --user restart sway-autorotate

# Check status
systemctl --user status sway-autorotate

# View logs
journalctl --user -u sway-autorotate -f

# Disable auto-start
systemctl --user disable sway-autorotate

# Re-enable auto-start
systemctl --user enable sway-autorotate
```

## What Didn't Work

### 1. iio-sensor-proxy with monitor-sensor (bash script)
- `monitor-sensor --accel` showed orientation changes when run manually
- But piping to a bash `while read` loop didn't trigger rotations reliably
- The pipe created subshell issues with swaymsg

### 2. iio-sensor-proxy D-Bus with dbus-python
- `ClaimAccelerometer()` call would hang/block indefinitely
- The dbus-python library had issues maintaining the connection

### 3. iio-sensor-proxy D-Bus with Gio (PyGObject)
- Claiming worked, but orientation never changed from "normal"
- The sensor proxy's buffer mode has issues: `Buffer '/dev/iio:device0' did not have data within 0.5s`
- Raw sysfs values changed, but iio-sensor-proxy didn't translate them

### 4. dbus-monitor approach
- Got `AccessDenied` errors for signal monitoring

### 5. Polling via gdbus command-line
- Each `gdbus call` is a separate process
- `ClaimAccelerometer` is released when the process exits
- Without an active claim, orientation stays "normal"

### 6. Systemd service without SWAYSOCK
- Service ran but swaymsg couldn't connect to Sway
- Fixed by wrapping in bash to find and export SWAYSOCK

### 7. Initial rotation directions
- Had 90/270 swapped - fixed by trial and error

### 8. Scale reset on rotation
- `swaymsg output eDP-1 transform 90` reset scale to 1.0
- Fixed by adding `scale 2` to each rotation command

## Known Issues

- After reboot, `iio-sensor-proxy` may need a restart for the accelerometer to work:
  ```bash
  sudo systemctl restart iio-sensor-proxy
  ```
  This is a known issue with HID sensors on this device.

## Device Info

- Laptop: ASUS ROG Flow Z13 (GZ302EA)
- Sensor: `accel_3d` HID sensor via ITE8353
- Display: eDP-1, 2560x1600, scale 2.0
- OS: Fedora 43, Sway on Wayland
