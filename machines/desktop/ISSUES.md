# Desktop Issue Tracking

Hardware and software issues for desktop (NVIDIA RTX 3090, Intel).

## Open Issues

### HDMI Audio Dropout to Monitor
- **Status:** Monitoring
- **Submitted:** 2025-12-30

#### Problem
Monitor audio (XB271HU via DisplayPort) occasionally drops out. Software shows correct sink selected, but no audio plays through monitor.

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
- Monitor: Acer XB271HU on DisplayPort (hdmi-output-0 / pro-output-3)
- Audio stack: PipeWire 1.4.9 with WirePlumber
- Card: `alsa_card.pci-0000_01_00.1` using pro-audio profile

#### Sources
- https://forums.developer.nvidia.com/t/audio-cuts-drops-hdmi-for-some-months-now/289514
- https://forums.developer.nvidia.com/t/audio-pass-through-via-hdmi-often-interrupted/270808
- https://wiki.archlinux.org/title/NVIDIA/Troubleshooting

## Resolved Issues

(none yet)
