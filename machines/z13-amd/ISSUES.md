# Z13 AMD Issue Tracking

Hardware and software issues for ROG Flow Z13 (GZ302EA) - 2025 model.

## Open Issues

### File Picker Dialogs Not Working in Sway
- **Status:** Testing fix
- **Submitted:** 2025-12-16

#### Problem
GTK file picker dialogs don't appear in applications (e.g., Obsidian "Open folder as vault"). This affects any app that uses xdg-desktop-portal for file dialogs.

#### Cause
`xdg-desktop-portal-gtk` service fails with `cannot open display:` because Sway wasn't exporting `WAYLAND_DISPLAY` to systemd user services.

#### Fix Applied
Added to `~/.config/sway/config` in STARTUP section:
```
exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```

#### Testing
- Manual fix worked (portal started successfully after env import)
- Sway reload doesn't apply `exec` commands - requires logout/login or reboot
- Waiting for reboot to confirm permanent fix

#### Notes
- Packages installed: xdg-desktop-portal, xdg-desktop-portal-gtk, xdg-desktop-portal-wlr
- Portal config at `/usr/share/xdg-desktop-portal/sway-portals.conf` correctly routes FileChooser to gtk

### Ollama Falls Back to CPU (gfx1151 Not Used)
- **Status:** Open - upstream issue filed
- **Submitted:** 2025-12-30
- **Issue URL:** https://github.com/ollama/ollama/issues/13589

#### Problem
Ollama silently falls back to CPU inference on Linux even though `rocminfo` correctly detects the gfx1151 GPU. The same hardware works with GPU on Windows.

```
$ ollama ps
NAME               ID              SIZE      PROCESSOR
granite4:latest    4235724a127c    2.4 GB    100% CPU
```

#### Environment
- ROCm 6.4.2 installed and detecting GPU correctly
- Kernel 6.17.12-300.fc43.x86_64
- Device permissions OK (/dev/kfd, /dev/dri/renderD128 world-accessible)

#### What's Been Tried
1. Built Ollama from main (post PR #13196 GTT fix) - still CPU
2. HSA_OVERRIDE_GFX_VERSION=11.5.0 - still CPU
3. Verified rocminfo shows gfx1151 as Agent 2 with KERNEL_DISPATCH

#### Related Issues
- #9553 - gfx1151 crashes on Windows
- #10993 - gfx1151 crashes on Windows
- #12062 - GTT memory fix (merged Dec 23, didn't help)

#### Notes
- Windows dual-boot uses GPU successfully
- No error messages - just silent fallback to CPU
- gfx1151 is listed as "supported" in Ollama docs
- Waiting for upstream fix

## Resolved Issues

### Large Models Fail to Load on Vulkan (RADV heap too small)
- **Status:** Resolved
- **Submitted:** 2026-08-15

#### Problem
Any model needing more than ~17.5 GiB of Vulkan heap died at load:

```
radv/amdgpu: Not enough memory for command submission.
error loading model: vk::Queue::submit: ErrorDeviceLost
```

`gemma4:31b` failed on every attempt. Lowering the GPU layer count did not
help — identical failure at 50/61, 40/61, 32/61 and 24/61 layers.

#### Cause
RADV on an APU exposes one pool of kernel VRAM + GTT (4 + 13.52 = 17.52 GiB),
split 1/3 : 2/3. Kernel GTT defaulted to `ttm.pages_limit`, which is half of RAM.

Ollama 0.32.13 (binary dated Aug 14) changed non-offloaded weights from mmap'd
`CPU_Mapped` pages to pinned `Vulkan_Host` buffers, which come out of that same
pool. So the total stayed at ~18893 MiB regardless of the layer split — always
~1.4 GiB over the ceiling. The same model loaded fine on Aug 07 with
`CPU_Mapped 17801 MiB + Vulkan0 13565 MiB`.

#### Fix Applied
```
sudo grubby --update-kernel=ALL --args="amdgpu.gttsize=20480 ttm.pages_limit=5242880"
```
Both are required; reboot needed. Details in `ollama/INSTALL.md`.

#### Testing
- Kernel GTT 13.52 -> 20.00 GiB, RADV heap 17.52 -> 24.00 GiB (8 + 16)
- `gemma4:31b` now reports `offloaded 61/61 layers to GPU` at 32k context
- Throughput 8.45 -> 11.3 tok/s (~201 GB/s of a ~256 GB/s peak)
- Vision projector fits on GPU; no more `--no-mmproj-offload` fallback

#### Notes
- Pins ~20 GiB of a 27 GiB pool. Swap is zram, not disk, so it cannot absorb a
  real overcommit — 31b at large context plus a heavy browser will be tight.
- `ollama/no-host.conf` is an uninstalled fallback (`LLAMA_ARG_NO_HOST=1`) for
  any future model that lands in partial offload and overflows again.
- Separate from the ROCm CPU-fallback issue above; that one is handled by the
  Vulkan systemd drop-in.

### Keyboard Backlight Not Working
- **Status:** Resolved (workaround)
- **Submitted:** 2025-12-05
- **Resolved:** 2025-12-10
- **Issue URL:** https://github.com/NeroReflex/asusctl/issues/101

#### Problem
Keyboard backlight doesn't turn on after cold boot to Linux. sysfs brightness writes succeed but produce no light.

#### Solution/Workaround
Boot into Windows first, then reboot into Linux. The keyboard backlight state persists in firmware/EC across reboots. On Linux boot, asusd eventually initializes and the backlight works.

**Observed behavior (2025-12-10):**
1. Booted Windows - keyboard dark initially
2. After Windows restart - keyboard lit up
3. Rebooted into Linux - keyboard lit during boot, briefly blocked typing (~30s), then worked normally
4. `asusctl -k low/med/high` now controls brightness

#### Device Info
- Model: ASUS ROG Flow Z13 (GZ302EA) - 2025 model
- OS: Fedora 43, kernel 6.17.9
- asusctl: 6.1.12

#### Logs
asusd shows model not in database but uses defaults:
```
[WARN] the aura_support.ron file has no entry for this model: GZ302EA, 18c6. Using a default
[INFO] Found keyboard LED controls at "asus::kbd_backlight"
```

#### Notes
- Windows/Armoury Crate initializes the keyboard LED controller in firmware
- Linux asusd can then read/write via `/sys/class/leds/asus::kbd_backlight/brightness`
- The ~30s input block on boot may be asusd probing the HID devices
- Cold boot directly to Linux still doesn't work - needs Windows boot first

#### Update 2025-12-10
Direct Linux boot now works - backlight visible without Windows boot first. Survived reboot.
- Never manually ran Armoury Crate - likely auto-installed/updated via Windows Update
- Windows background services may have updated EC firmware or LED defaults
- Testing full shutdown next to confirm fix is permanent
