# Desktop Issue Tracking

Hardware and software issues for desktop (NVIDIA RTX 3090, Intel).

## Open Issues

### Dual 3090 & Quad 3090 Local AI Infrastructure Expansion
- **Status:** Open / Procurement & Testing
- **Submitted:** 2026-07-23

#### Problem
Need high-throughput, low-cost local LLM inference and agentic execution (96GB VRAM target) to run 70B and MoE models (Gemma 4 26B/31B, Llama 3 70B) locally at zero API token cost, outperforming Mac Studio setups without VC hardware lock-in.

#### Interconnect ceiling on this board (verified 2026-08-09)

**The MSI MPG Z390 Gaming Plus runs x16/x4, and the second full-length slot is fed by the chipset, not the CPU.**

| Slot | Width | Source |
|---|---|---|
| PCI_E1 | x16 | CPU |
| PCI_E4 | **x4** | **PCH** |

Officially CrossFire-capable, **not SLI-certified** — NVIDIA requires x8/x8 minimum, which this board cannot provide. Consequences that matter more than any GPU spec:

- The second card gets **PCIe 3.0 x4 ≈ 3.9 GB/s**, not the x8 a lane-split board would give.
- Those are **PCH lanes sharing the DMI 3.0 uplink** (~3.9 GB/s total) with the M.2 NVMe, SATA, USB, and LAN. Under load the effective figure is lower still.
- Without NVLink, GPU↔GPU traffic routes **GPU2 → PCH → DMI → CPU → GPU1**. That is the worst possible path for tensor parallelism.
- The 9900KF only has 16 CPU lanes total, so no board-level fix exists here. **This is precisely what Phase 2's EPYC (128 lanes) is for.**

**Note which slot the vertical card lands in.** If the riser plugs into PCI_E4, the vertically-mounted card is the x4 one — that is the configuration being benchmarked.

#### Dual-GPU performance predictions — pre-registered 2026-08-09

Written **before** benchmarking so the results cannot be rationalized afterward.

1. **EVGA vs Zotac, single card: parity, within 1–3%.** Same GA102, 10496 cores, 24GB GDDR6X. Expect a tie in short bursts; the EVGA XC3's 2.2-slot cooler may throttle sooner than the Trinity's 2.5-slot under sustained load, showing up as a slow decline rather than a lower peak.
2. **Mismatched 3090 + 2080: no pooling benefit; expect ≈ single-3090 or worse.** Turing (SM 7.5) has no bf16, so the whole stack is pinned to fp16. vLLM tensor parallelism assumes homogeneous GPUs and would cap at 2× the smaller card, stranding 16GB of the 3090. llama.cpp's uneven layer split does work, but the 2080's 448 GB/s against the 3090's 936 GB/s makes those layers roughly half-speed. Real value here is **independent** workloads on the 2080 (display, Whisper, TTS, encode), not pooling.
3. **True dual 3090 — split by framework:**
   - **Tensor parallel (vLLM): expected to disappoint on this board**, bottlenecked by the x4 PCH link above rather than by the cards.
   - **Layer split (Ollama / llama.cpp): expected to be the usable path**, since it moves far less data across the interconnect.
   - **Capacity win is real regardless of interconnect:** 48GB holds a 70B at Q4 (~40GB) that a single 3090 simply cannot, at any speed.
   - **For models that already fit in 24GB, dual may be *slower* than single at batch-1** once communication overhead is counted. Gains show up in batched/concurrent serving.

**Interpretation warning:** if the dual numbers come in poor, the likely cause is the x4 PCH link, **not the GPUs**. Do not conclude "dual 3090 isn't worth it" from results on this board — that conclusion would be an artifact of the platform Phase 2 exists to replace.

**To capture during the benchmark:**
- `lspci -vv | grep -i LnkSta` — negotiated width per card, confirming which is on x4
- `nvidia-smi topo -m` — whether NVLink is present
- Single-card baseline for each card separately, same model and quant
- Dual on a model that fits 24GB (measures TP overhead) **and** a 70B Q4 (measures the capacity win)

**NVLink is the one available lever.** The 3090 is the only consumer Ampere card with it (~112 GB/s, bypassing PCIe entirely), roughly $80–150. On this board it would matter more to tensor-parallel throughput than anything else in the build — though it helps layer-split workloads much less.

#### Hardware Strategy & Milestones
- **Card #1 (EVGA RTX 3090 XC3 24GB):** Purchased 2026-07-23 for $1,099 + tax/shipping ($1,200 all-in). Delivery expected 7/25–7/29.
- **Existing card (Zotac RTX 3090 Trinity, in the first x16 slot):** 2.5 slots thick (58mm), 292mm length. Identified from case photos by branding/styling, not a confirmed exact SKU — verify against box/invoice if precision ever matters beyond clearance planning.
- **Incoming card (EVGA RTX 3090 XC3, non-Ultra):** 2.2 slots thick, 285mm length, per [EVGA's spec page](https://www.evga.com/products/specs/gpu.aspx?pn=0af3074a-125d-41e4-a458-781632ded173).
- **Slot clearance problem, measured 2026-07-24 (final count via physical test-fit with a spare ASUS RTX 2080 OC, 2.7 slots, as a dummy card):** case has **7 total expansion-slot positions**. Slot 1: unused. Slots 2-3: Zotac's native footprint. Slots 4-5: open gap. Slots 6-7: the only remaining bracket pair large enough for a second card's I/O bracket — not a free choice, the only option given 7 slots total. Net: **~1.5-slot (~30mm) real gap between the two cooler shrouds** (2-slot nominal gap at positions 4-5, minus ~0.5 slot eaten by both cards' own overhang beyond their marked slot range), and **~1-slot (~20mm) clearance from the EVGA down to the PSU shroud** at the bottom of the case. The PSU-shroud number is a physical-fit constraint, not a thermal one (PSU has its own independent intake); the 30mm inter-card gap is the thermally meaningful figure, since that's the EVGA's actual intake air quality. Cross-check: the 2.7-slot ASUS dummy measured ~0.3-slot clearance to the PSU shroud in the same slots-6-7 position; the real EVGA (2.2 slots, 0.5 slot thinner) projects to ~0.8-1.0 slot — consistent 1:1 scaling with the thickness difference.
  - **Fix: PCIe riser cable**, relocating card #2 from its native connector to the slots-6-7 bracket position for the ~30mm gap above. **Chosen 2026-07-24: OwlTree PCIe 4.0 x16 90°, 20cm, EMI-shielded, 30AWG** (~$27, 4.5★/18 reviews, explicitly 3090-tested and PCIe 3.0-system compatible — matters since the native second slot is chipset-connected and likely only Gen3 x4 electrically regardless of riser). Signal instability would be a second variable tangled with the existing AC-noise/OCP crash history (see [[project_3090_power_cap]]), hence the shielded/reviewed pick over a cheap mining-style cable.
  - **SUPERSEDED 2026-07-24 (real hardware inspection, not just measurement):** Erik physically examined the actual board and found the second physical slot sits **3 slot-rows below the first, not 2** as assumed throughout the drawing exercise above — and, more importantly, concluded that **no flexible flat ribbon riser can be mechanically anchored between the native slot and the slots-6-7 bracket at all** (a flat ribbon has nothing rigid to screw into at the card end unless paired with a proper connector housing). The OwlTree flat-ribbon plan above is likely not viable as specified. **Current real direction: a dual-90°-connector riser cable (rigid housings at both ends, e.g. Thermaltake AC-077-CO1OTN-C1, 400mm) combined with vertical GPU mounting** for the EVGA, rather than same-panel bracket relocation to slots 6-7. Fractal's own official kit for this case is the **Flex VRC-25** (cable + rigid standoff frame, PCIe 3.0, officially rated 31mm total clearance / <38mm recommended card thickness — the EVGA's 48mm exceeds that, so expect it to run hot); a generic bracket may also work since Erik runs the case **open** (no side panel), which removes the main reason vertical-mount kits need to match a specific case's glass-clearance depth. Independent (non-vendor) reports confirm generic vertical risers commonly collide with a case's PSU shroud if not dimensioned for it — a real mechanical concern, not pure vendor lock-in, though largely moot for an open-case build. **Fractal's official VRC-25 kit turned out to not be practically obtainable** (only found via an international UAE reseller, real logistics friction); the newer **Flex 2** kit doesn't list Define R6 compatibility and requires "bridgeless" expansion slot covers — this case's rear latch is a bridged hinged-bar design (confirmed from a real photo), so Flex 2 is likely not compatible either. A "flip EVGA to point fans away from the shared gap" idea was also examined and **ruled out as not physically workable** on inspection. Considered and rejected: mounting the second card upside-down in slots 6-7 so both cards' fans face each other into the shared gap — theoretically protects nothing for the Zotac (its own fan-facing direction into the gap never changes regardless of EVGA's orientation), so it doesn't fix the card that matters most.

**SUPERSEDED 2026-08-09 — dual now fits the existing case, horizontal + vertical.** A different riser cable (model not yet recorded) plus a **180° GPU power connector** clears the plug-side constraint that drove the whole exploration below. No bracket relocation to slots 6-7, no VRC-25, no Thermaltake cable, and no sell-the-Zotac fallback. Two cards run in the Define R6 as-is: one horizontal in its native slot, one vertical in the case's existing vertical cutouts.

- **Card assignment (decided 2026-08-09):**
  - **Benchmark configuration, first:** both 3090s — one horizontal, one vertical. This is the step that **gates every downstream decision** and it is not optional; dual performance may turn out to be unbeatable, in which case the split below does not happen at all.
  - **End state if the split proceeds:** **EVGA 3090 XC3 horizontal + ASUS 2080 vertical** in this machine; **Zotac 3090 moves to System 2** (`machines/parts/README.md`).
  - Sending the Zotac rather than the EVGA is the right way round on two counts: the Zotac is the thicker card (2.5-slot / 292–320mm vs the EVGA's 2.2-slot / 285mm), so the tighter remaining space gets the slimmer card; and the Zotac is the one with real sag-damaged fans, which is easier to support in a fresh build than in this case's contested space. It still needs its upHere G195BK brace wherever it lands.
- **To record when installed:** the actual riser cable model and the 180° connector part, so this is reproducible. Everything below is retained as history of what was ruled out.

**Superseded plan (2026-07-24, revised same day, evening): vertical mount was the CURRENT plan** — Thermaltake dual-90° 400mm cable + DIY M3 standoffs into the PSU shroud's existing threaded holes, EVGA vertical, Zotac unchanged in its normal first slot (no swap needed). **Fallback: the horizontal swap-stack run hot** (EVGA on top — order is load-bearing: 3-row pitch 60.96mm minus EVGA's 2.2-slot thickness ≈ 0.8-slot/~13-16mm clearance; Zotac-on-top would leave ~3mm, unworkable). Final fallback if both prove unacceptable: **sell the Zotac** rather than keep fighting the case's mounting constraints.

**Vertical-mount option, refined 2026-07-24:** the real Fractal VRC-25 kit surfaced on Amazon ($8.99, Define R6 explicitly listed) but turned out **not actually in stock** despite the listing — confirmed false positive, don't trust "in stock" indicators without checking the actual buy flow. The VRC-25's own product photos were still useful independent of purchasability: they show real rigid-PCB connector boards at **both** ends (motherboard-side and card-side), each shaped like a standard slot bracket (normal thumbscrew-hole profile — confirms both ends mount via ordinary rear-panel slot openings, not a proprietary cutout), with a visible offset at each end between the board's own mounting screw holes and the actual electrical connector position — the concrete "offset" concept this whole exploration was chasing. The kit's own hardware (2 standoffs + 2 screws, visible in the photo) confirms genuine kits do include real mounting hardware, unlike the Thermaltake cable (confirmed elsewhere to be cable-only, no standoffs — every listing markets it purely on cable specs, never mounting hardware, unlike VRC-25/Cooler Master's kits which lead with that as a feature). **Live plan if pursued: Thermaltake PCI-E 4.0 Dual 90° Riser Cable 400mm Snow (AC-077-CO6OTN-C1)** — sold out direct from Thermaltake, but in stock at Newegg ($64.99) and AeroCooler ($74.99) as of 2026-07-24 — paired with a cheap generic M3 nylon standoff/spacer assortment (~$7.58, Amazon) for the DIY PSU-shroud rest point, informed by the offset geometry visible in the VRC-25 photos even though that exact kit isn't buyable.
  - **Sag support, decided 2026-07-24:** real prior damage — the Zotac 3090's fans were already damaged by sag after being reinstalled twice unsupported (the older ASUS 2080 OC, physically bigger/heavier, never sagged or degraded in the same slot over much longer use — card-specific cooler/fan-clearance tolerance, not a weight effect). Existing brace doesn't fit the new geometry. **Zotac (proven damage): upHere G195BK** — fixed 19.5cm pole with a sliding clamp arm (not a segmented telescoping design), so it isn't floored at a minimum extension height and can seat close to the base if needed. **EVGA (lower/riser-mounted, ~16mm gap to PSU shroud): improvised wood dowel/chopstick, cut to exact height** — more reliable than forcing a manufactured bracket into an oddly-specific tight gap, non-conductive, trivial to trim precisely.
  - **Do all physical install/cable work with the PSU switched off, not just OS-shutdown** — a live-cable mishap during test-fitting already caused one full system crash this session (2026-07-24), a new failure mode independent of the documented AC-noise/OCP one.
  - **Slots 6-7 chosen over 5-6, decided 2026-07-24:** the alternative (5-6) trades to 0.8-slot inter-card gap / 1.5-slot PSU clearance — the reverse allocation. Rejected because both cards' fans face directly into the inter-card gap (confirmed by physical inspection), making that gap the dimension that actually governs GPU-to-GPU thermal recirculation; PSU proximity is comparatively low-stakes since the PSU has its own independent intake and tolerates nearby ambient heat better than a GPU tolerates re-breathing the other GPU's exhaust. 6-7 (1.5 inter-card / 0.8 to PSU) keeps the gap where it matters most.
- **Phase 1 (Desktop Testing):** ⚠️ **BLOCKED — the 750W PSU this plan depends on blew on 2026-07-27** ("popped loudly and expelled gas thru vent"). Corsair RMA #2009087410 is approved and the warranty replacement is a **RM1000x, 1000W** (`CP-9020271-NA`), with an 850W running temporarily; two RAM sticks also died in the incident (the board was suspected but is fine). Re-derive the power budget below against the 1000W unit once it lands — it is more headroom than this plan assumed. RMA window closes ~2026-08-28 and the replacement only ships after the dead unit is received. See `machines/parts/README.md`. ~~Test dual 3090s (existing 3090 + EVGA XC3) on current desktop (MSI Z390 / i9-9900KF) using existing 750W PSU with power capping (`nvidia-smi -pl 200` or `250` for ~500W–550W total system load).~~ Validate 48GB VRAM pool, vLLM / Camelid / Ollama multi-GPU tensor parallelism.
  - **Dual is a benchmark configuration, not the end state (decided 2026-08-09).** The target for this machine is **mixed** — one 3090 plus the ASUS 2080 — with the **second 3090 moving to the System 2 build** (`machines/parts/README.md`). The dual config exists only long enough to capture multi-GPU numbers; the cards split afterward. Power is not the blocker for that benchmark: the interim 850W already exceeds the ~500–550W this plan budgeted against a 750W unit. The blocker is the unresolved EVGA mounting problem above.
  - *Safety Exit:* superseded. If the dual numbers don't justify expansion, the EVGA goes into System 2 rather than back on eBay — it is now that build's GPU.
- **Phase 2 (Quad Rig Build):** Swap the RTX 2080 into desktop for lightweight display/gaming (ASUS ROG STRIX RTX 2080 Overclocked 8G — this machine's original 2019 card, see `machines/parts/README.md`; earlier notes calling it a "2080 Super" were a conflation, Super is a different die). Procure Cards #3 & #4 (RTX 3090s, target <= $1,200/ea), AMD EPYC 7000 CPU + Mobo combo (128 PCIe Gen4 lanes), dual 1200W ATX PSUs, and open-air / 4U frame.
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
