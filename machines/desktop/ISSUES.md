# Desktop Issue Tracking

Hardware and software issues for desktop (NVIDIA RTX 3090, Intel).

## Open Issues

### HDMI Audio Dropout to Monitor
- **Status:** Monitoring
- **Submitted:** 2025-12-30

#### Problem
Monitor audio (Acer Predator XB271HU via DisplayPort) occasionally drops out. Software shows correct sink selected, but no audio plays through monitor.

#### Symptoms
- Audio stops playing through monitor
- `wpctl status` shows correct sink selected
- ELD files show `monitor_present=0, eld_valid=0` when broken
- No errors in logs

#### Root Cause
GPU memory clock transitions cause HDMI/DP audio to drop. This is a known NVIDIA driver bug affecting RTX 30/40 series on Linux. When the GPU reclocks (changes power states), the audio connection drops.

#### Current Workaround
Power cycle the monitor (full power off, not just standby). Software restarts (PipeWire, kernel module reload) do not help.

#### Potential Fix: Lock Memory Clocks
Test temporarily:
```bash
sudo nvidia-smi -lmc 810,9751  # Lock memory clocks
sudo nvidia-smi -rmc           # Undo
```

Make permanent with systemd service `/etc/systemd/system/nvidia-hdmi-audio-fix.service`:
```ini
[Unit]
Description=Lock NVIDIA memory clocks for HDMI audio stability
After=nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -lmc 810,9751
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl enable --now nvidia-hdmi-audio-fix.service
```

**Trade-off:** Slightly higher idle power consumption.

#### Hardware Info
- GPU: NVIDIA GA102 (RTX 3090)
- Monitor: Acer Predator XB271HU on DisplayPort (hdmi-output-0 / pro-output-3)
- Audio stack: PipeWire 1.4.9 with WirePlumber
- Card: `alsa_card.pci-0000_01_00.1` using pro-audio profile

#### Sources
- https://forums.developer.nvidia.com/t/audio-cuts-drops-hdmi-for-some-months-now/289514
- https://forums.developer.nvidia.com/t/audio-pass-through-via-hdmi-often-interrupted/270808
- https://wiki.archlinux.org/title/NVIDIA/Troubleshooting

### Waybar Whiteout
- **Status:** Open
- **Submitted:** 2025-12-30

#### Problem
Waybar modules (CPU, GPU) occasionally whiteout and become completely unreadable. Text turns white/invisible against the background.

#### Symptoms
- Started on GPU module, now occurs most frequently on CPU module
- Most reproducible after GPU reaches 100% utilization
- Also occurs randomly on CPU module without GPU load
- Has occurred right before system crashes despite GPU power being capped at 95%
- **2025-12-31:** First occurrence on audio module (not just CPU/GPU)
- **2025-12-31:** First persistent whiteout - didn't clear after sway reload or killall waybar

#### Attempted Fixes
Several fixes have been attempted but none have been permanent:
- **2025-12-29:** Removed pango markup from `cpu.sh` - switched to plain text output with CSS classes instead of inline `<span>` tags (commit ca217b4). Previously applied same fix to `gpu.sh`.
- **2025-12-30:** Attempted `!important` on color rules - **FAILED** - GTK CSS (used by waybar) doesn't support `!important`, caused CSS parse errors and broke waybar. Reverted.
- **2025-12-30:** Added explicit `background-color: #1a1a1a` to all CPU/GPU CSS rules. If text turns white, it will still be readable against dark background.

#### Potential Causes
- Pango markup errors in waybar scripts
- GPU memory/power state transitions affecting rendering
- Possible correlation with GPU hitting power limits
- DDC/CI commands (ddcutil) can trigger the whiteout

#### Related
- GPU power limit set to 95% (332W) via `gpu-power-limit.service`

### Keyboard Brightness Keys Not Detected
- **Status:** Open
- **Submitted:** 2025-12-31

#### Problem
Fn+1/2 keys intended for monitor brightness control don't generate any keycodes visible to Wayland/sway. `wev` shows no key events when pressing these combinations.

#### Symptoms
- `wev` shows only `modifiers` and `enter/leave` events, no `keycode` or `sym` output
- Fn+4/5 (volume) reportedly work, but weren't tested with wev
- Even plain F1/F2/F4/F5 keys showed no keysym output in wev (may be focus issue)

#### Current State
- DDC/CI brightness control is working (script + waybar module added)
- Keybindings set up for `XF86MonBrightnessUp/Down` and `$mod+F4/F5` fallback
- Need to identify correct keycodes or use alternative bindings

#### To Investigate
1. Test `wev` with simple key (letter 'a') to confirm wev is receiving events
2. Identify keyboard model and check if Fn keys are hardware-only
3. Check if keyboard software can remap Fn+1/2 to send brightness keycodes
4. Consider alternative keybindings if hardware Fn keys can't be used

#### Workaround
Use `$mod+F4` (brightness down) and `$mod+F5` (brightness up), or click/right-click the BRT waybar module.

## Resolved Issues

(none yet)
