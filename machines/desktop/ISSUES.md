# Desktop Issue Tracking

Hardware and software issues for desktop (NVIDIA RTX 3090, Intel).

## Open Issues

### Dual 3090 & Quad 3090 Local AI Infrastructure Expansion
- **Status:** Open / Procurement & Testing
- **Submitted:** 2026-07-23

#### Problem
Need high-throughput, low-cost local LLM inference and agentic execution (96GB VRAM target) to run 70B and MoE models (Gemma 4 26B/31B, Llama 3 70B) locally at zero API token cost, outperforming Mac Studio setups without VC hardware lock-in.

#### Hardware Strategy & Milestones
- **Card #1 (EVGA RTX 3090 XC3 24GB):** Purchased 2026-07-23 for $1,099 + tax/shipping ($1,200 all-in). Delivery expected 7/25–7/29.
- **Phase 1 (Desktop Testing):** Test dual 3090s (existing 3090 + EVGA XC3) on current desktop (MSI Z390 / i9-9900KF) using existing 750W PSU with power capping (`nvidia-smi -pl 200` or `250` for ~500W–550W total system load). Validate 48GB VRAM pool, vLLM / Camelid / Ollama multi-GPU tensor parallelism.
  - *Safety Exit:* If performance/workflow doesn't justify expansion, re-list EVGA 3090 XC3 on eBay to recoup ~100% investment.
- **Phase 2 (Quad Rig Build):** Swap RTX 2080 Super into desktop for lightweight display/gaming. Procure Cards #3 & #4 (RTX 3090s, target <= $1,200/ea), AMD EPYC 7000 CPU + Mobo combo (128 PCIe Gen4 lanes), dual 1200W ATX PSUs, and open-air / 4U frame.
- **Phase 3 (Monetization & Decommission):** Rent out Quad 3090 (96GB VRAM) server compute via Vast.ai / RunPod or local air-gapped business API seats until hardware costs are amortized (~5–6 months). Evaluate selling heavy desktop tower and using z13 laptop + Chromebooks + dedicated Quad AI server.

### Sway Multi-Monitor Workspace Assignment Discrepancies
- **Status:** Open / Planning Refactor
- **Submitted:** 2026-07-21

#### Problem
In Sway on desktop, moving containers to specific workspaces (e.g. `$mod+Shift+2` or `$mod+Shift+4`) behaves inconsistently compared to single-monitor setups (like laptop `z13-amd`).

#### Symptoms
- Moving a container to WS 2 (`$mod+Shift+2`) causes it to jump physically to DP-3 (secondary monitor on the left).
- Moving a container to WS 4 (`$mod+Shift+4`) stays on the current focused monitor because WS 4 is assigned to `DP-1` which is currently disabled (`output DP-1 disable`).
- On laptop, all workspaces live on `eDP-1`, so moving windows between workspaces never changes physical screens unexpectedly.

#### Root Cause
[`outputs.conf.desktop`](file:///home/blueaz/.dotfiles/sway/.config/sway/config.d/outputs.conf.desktop) hardcodes:
- `workspace 1 output DP-2`
- `workspace 2 output DP-3`
- `workspace 3 output DP-1` (Disabled output)
- `workspace 4 output DP-1` (Disabled output)

#### Planned Fix
- Decide whether to remove hardcoded workspace output assignments (allowing workspaces to dynamically land on the active monitor like laptop) or clean up disabled `DP-1` references.

### HDMI Audio Dropout to Monitor & Hotkey Cycling Redesign
- **Status:** Open / Planning Redesign
- **Submitted:** 2025-12-30 (Updated 2026-07-21)

#### Problem
Monitor audio (Acer Predator XB271HU via DisplayPort) occasionally drops out due to GPU memory clock reclocking. To work around audio routing issues, two separate hotkey combinations are currently used to cycle audio:
- `$mod+Mod1+F11`: `cycle-audio-source.sh` (cycles sink: monitor -> built-in -> earpods)
- `$mod+Mod1+F2`: `cycle-video-audio.sh` (cycles NVIDIA pro-audio sub-sinks `pro-output-*`)

Having two separate cycling hotkeys is cumbersome and non-intuitive when monitor DP audio drops out.

#### Planned Solution
- Combine and streamline audio cycling logic into a single smart toggle/script that checks sink health and automatically skips/falls back from broken monitor DP channels.


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
