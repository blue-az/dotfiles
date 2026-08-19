# Apple iPhone 15 Pro

## Device Info

| Property | Value |
|----------|-------|
| Model | iPhone 15 Pro |
| Identifier | iPhone16,1 |
| Model Number | MTQM3 |
| Hardware | D83AP (t8130) |
| iOS | 18.6.2 (update when upgraded) |
| CPU | arm64e |
| Carrier | T-Mobile US |
| UDID (this unit) | `00008130-000214E90891401C` |

## Status
- Stock iOS
- Not jailbroken

---

## Media extraction (what actually works)

Two host profiles exist. **Prefer the z13 path below** — it is the first stable pull we got on the laptop.

### Preferred on z13 (ifuse / libimobiledevice) — proven 2026-08-08

Pulls straight from the phone’s `DCIM/` tree after lockdown pairing. This is what finally worked for `IMG_0281.MOV` (Proximity / ProxSensor).

#### Preparation
1. Connect the iPhone via USB (**data** cable; prefer a direct port, not a flaky hub).
2. **Unlock** the iPhone and leave the screen on.
3. When the dialog appears, tap **Trust** and enter the passcode.  
   - On z13 the Trust sheet can **flash** instead of staying up (see Troubleshooting). Re-enter the passcode when it sticks.
4. Close any file-manager “iPhone” window (it steals the USB claim).

#### Pair and check
```bash
systemctl is-active usbmuxd    # should be active; if not: sudo systemctl start usbmuxd
idevice_id -l                  # expect UDID
idevicepair validate           # SUCCESS: Validated pairing with device …
# if not paired:
idevicepair pair               # then Trust + passcode on phone
idevicepair validate
```

#### Mount, copy one file, unmount
```bash
MNT=$(mktemp -d -t iphone-mnt.XXXXXX)
ifuse "$MNT"
ls "$MNT/DCIM"                 # e.g. 100APPLE
find "$MNT/DCIM" -iname 'IMG_0281*'

# example: pull by name into ProxSensor workspace
mkdir -p ~/Videos/ProxSensor ~/Pictures/iPhone-Import/prox-281
cp -v "$MNT/DCIM/100APPLE/IMG_0281.MOV" ~/Videos/ProxSensor/
cp -v "$MNT/DCIM/100APPLE/IMG_0281.MOV" ~/Pictures/iPhone-Import/prox-281/
# optional still/thumbnail if present under PhotoData — prefer DCIM for full media

fusermount -u "$MNT"
rmdir "$MNT"
```

#### Bulk / incremental (script)
```bash
iphone-import --check
iphone-import --since 2026-05-01 ~/Videos/ProxSensor
# default dest: ~/Pictures/iPhone-Import/YYYY-MM-DD/
```
`iphone-import` uses the same stack (usbmuxd → pair → ifuse → DCIM). Prefer it for bulk; use the manual `ifuse`/`cp` when you need one named file under a flaky link.

#### Proven pull (2026-08-08, z13)
| Item | Result |
|------|--------|
| Method | `idevicepair validate` OK → `ifuse` → copy from `DCIM/100APPLE/` |
| File | `IMG_0281.MOV` (~12 MB, 1080p HEVC, ~10.7 s) + still/THM |
| Dest | `~/Videos/ProxSensor/` and `~/Pictures/iPhone-Import/prox-281/` |
| Note | First **stable** laptop pull after many Trust-flash failures; gphoto2 alone was too flaky on z13 |

---

### Alternate on desktop (gphoto2 PTP)

Documented earlier for the **desktop** host. Works when the USB session stays up long enough for PTP.

```bash
idevicepair validate
gphoto2 --auto-detect          # note port, e.g. usb:001,012 (changes every plug)
gphoto2 --port usb:… --camera 'Apple iPhone 5 (PTP mode)' \
  --folder /store_00010001 --list-files --recurse
# folders often look like /store_…/YYYYMM_a
gphoto2 --port usb:… --camera 'Apple iPhone 5 (PTP mode)' \
  --folder /store_…/YYYYMM_a --get-file N --force-overwrite
```

On z13, store IDs **renumber constantly** (`store_00010002` → `…09` → `store_feedface` when locked/limited). That is why PTP “directory not found” races are common; **ifuse + DCIM** avoids depending on those IDs.

---

## Troubleshooting

### Trust dialog flashes and disappears (z13)
**Cause:** USB reconnect loop + `usbmuxd` in systemd mode (exit when no device). Journal shows connect → config `0→4` → drop in ~1 s → `usbmuxd -x` → restart → new bus address. Desktop stays connected long enough; z13 often does not.

**Mitigations:**
1. Unlock + re-enter passcode when Trust finally sticks (worked 2026-08-08).
2. Direct port / known-good data cable.
3. Do not open the phone in a GUI file manager during pair/pull.
4. Optional host stabilizers (sudo):
   ```bash
   # after device is visible under /sys/bus/usb/devices/*/idVendor == 05ac
   echo on | sudo tee /sys/bus/usb/devices/…/power/control
   echo -1 | sudo tee /sys/bus/usb/devices/…/power/autosuspend
   ```
5. Stale lockdown (sudo), then replug and re-pair:
   ```bash
   sudo rm -f /var/lib/lockdown/*.plist
   idevicepair pair
   ```

### `idevicepair` / lockdownd errors
- **Invalid HostID (-21)** / not paired: `idevicepair pair` + Trust + passcode; or wipe lockdown plists (above).
- **Error -5** during pair: usually locked phone or Trust dismissed too fast — unlock and retry immediately.
- **`store_feedface` in gphoto2 storage-info**: limited/locked PTP view — unlock phone and retry; prefer ifuse once paired.

### gphoto2 / ifuse claim failures
- **"Could not claim the USB device"**: kill competing mounts (`fusermount -u` any `iphone-mnt*`; close file managers; avoid concurrent gphoto2 + ifuse).
- **"PTP Timeout"**: unlock + Trust + replug.
- **Empty `DCIM` after ifuse**: unlock phone; confirm pair with `idevicepair validate`.

### Packages (Fedora)
```bash
sudo dnf install usbmuxd ifuse libimobiledevice-utils libheif-tools libheif-freeworld
```

---

## Related paths

| Path | Role |
|------|------|
| `~/.local/bin/iphone-import` | Bulk import script (ifuse-based) |
| `~/Pictures/iPhone-Import/` | Default import destination |
| `~/Pictures/DistanceSensor/` | Earlier proximity stills pull |
| `~/Videos/ProxSensor/` | Proximity video workspace (IMG_0281.MOV, …) |
| `~/iphone-mnt` | Optional fixed mount point (often empty when unused) |
