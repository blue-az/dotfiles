# Apple iPhone 15 Pro

## Device Info

| Property | Value |
|----------|-------|
| Model | iPhone 15 Pro |
| Identifier | iPhone16,1 |
| Model Number | MTQM3 |
| Hardware | D83AP (t8130) |
| iOS | 18.6.2 |
| CPU | arm64e |
| Carrier | T-Mobile US |

## Status
- Stock iOS
- Not jailbroken

## Photo Extraction Workflow (Linux/Fedora)

This procedure works reliably on the `desktop` machine using `gphoto2`.

### 1. Preparation
1. Connect the iPhone via USB.
2. Unlock the iPhone.
3. If prompted, tap **Trust** on the iPhone and enter the passcode.

### 2. Validation & Detection
Verify the device is paired and find the current USB port:
```bash
idevicepair validate
gphoto2 --auto-detect
```
*Note: The port (e.g., `usb:001,012`) may change each time the device is reconnected.*

### 3. Locating Photos
Photos are typically stored in `/store_00010001/YYYYMM_a`.
To list files in a specific folder:
```bash
gphoto2 --port usb:001,012 --camera 'Apple iPhone 5 (PTP mode)' --folder /store_00010001/202605_a --list-files
```

To search for specific image numbers (e.g., 209 and 210):
```bash
gphoto2 --port usb:001,012 --camera 'Apple iPhone 5 (PTP mode)' --folder /store_00010001 --list-files --recurse | grep -E "209|210"
```

### 4. Downloading Photos
Download files by their local index within a folder:
```bash
# Navigate to target directory first
cd ~/Pictures/LinkedIn
gphoto2 --port usb:001,012 --camera 'Apple iPhone 5 (PTP mode)' --folder /store_00010001/202605_a --get-file 3-4 --force-overwrite
```

### Troubleshooting
- **"Could not claim the USB device"**: Ensure no other process (like a file manager) is accessing the iPhone.
- **"PTP Timeout"**: Reconnect the cable and ensure the phone is unlocked and trusted.
- **Empty folders**: Use `--recurse` with `--list-files` to find where the actual media is stored (usually `/store_00010001`).
