---
id: pbc_gpu_wallpaper_monitor
title: "Dual-GPU Wallpaper Monitor — Behavior Contract"
context: local-lane-monitoring
status: draft
tags:
  - pbc
  - local-lane
  - gpu
  - testbench
  - wallpaper
updated: 2026-09-26
---

# Dual-GPU Wallpaper Monitor — Behavior Contract

## Intent

Provide a calm, persistent desktop display for the headless benchmark
hardware. The implementation target is the wallpaper overlay Waybar instance
(`~/.config/waybar/config-overlay` + `~/.config/waybar/sysinfo.sh`), not a
terminal popup. The compact monitor bar (`config-monitor` +
`scripts/monitor.sh`) shows this desktop's CPU and GPU and must not be changed
by this work.

Revised 2026-09-26 (owner decision): the bar is desktop, the overlay is
testbench. The overlay shows only the `testbench` GPUs; the original
2026-09-11 draft also put the desktop GPU on the overlay, which is superseded.

## Scope

- The overlay shows the remote headless `testbench` GPUs; the desktop GPU is
  not shown there (the bar already shows it).
- The bar keeps showing this desktop's CPU and GPU, unchanged.
- The headless testbench currently has two RTX 3090 cards; both cards must be
  represented independently, not summed into one number.
- Use the existing dashboard visual language and continuously update without
  terminal repaint flashes or popup-window focus behavior.
- Show, when available, per GPU: host, GPU name, utilization, temperature,
  power draw, power limit, memory used/total, and active model/process context.
- Label the surface as `testbench` (overlay title `HEADLESS MONITOR`) and
  identify each card by a stable label (PCI bus ID or GPU index plus name).

## Non-goals

- Do not redesign Waybar or change the bar module.
- Do not change model routing, Ollama model files, GPU power limits, or CUDA
  visibility on either machine.
- Do not silently treat unavailable remote telemetry as zero.
- Do not expose secrets, SSH private material, or arbitrary remote shell output
  in the dashboard.
- Do not deploy unrelated website changes.

## Operational requirements

- Remote collection must fail closed: timeout and display `unreachable` or
  `unavailable` with a timestamp rather than hanging or showing stale values as
  current.
- The remote endpoint must be read-only telemetry. It may use the existing
  SSH configuration for `testbench`, but must not restart services or mutate
  the testbench.
- The dashboard must remain usable when `testbench` is offline.
- The overlay remains a quiet always-visible wallpaper monitor: no terminal
  window, no popup, no flashing repaint, and no focus behavior.
- The overlay title must visibly read `HEADLESS MONITOR` so the owner can
  distinguish this surface from the ordinary system overlay.

## Verification

- Unit or focused tests cover parsing two remote NVIDIA rows, one missing
  row, unavailable remote telemetry, and stale-data labeling.
- Live smoke proof on the desktop shows two independent `testbench` rows while
  the testbench is idle.
- Live smoke proof with the testbench unreachable shows an explicit unavailable
  state and returns promptly.
- Record the exact source paths, timestamp, hostnames, and observed values in
  an evidence artifact. This monitor is observability, not benchmark evidence.

## Status (2026-09-26)

The overlay was implemented in dotfiles `f5e67d8`. That commit also switched
the bar to the testbench, against this contract; the bar has since been
restored to the desktop GPU.

- Done: the overlay reads both testbench cards over SSH with a 2 s timeout;
  its title reads `HEADLESS MONITOR`; it shows name, utilization, temperature,
  power and memory per card, and `TB GPU unavailable` when the testbench is
  unreachable. The bar shows the desktop CPU and GPU.
- Open: a timestamp on the unavailable state and stale-data labeling; power
  limit (read but not displayed) and active model/process per card; stable card
  labels (EVGA/ZOTAC are assigned by nvidia-smi row order, not PCI bus ID);
  focused tests and the evidence artifact under Verification.

## Acceptance

The owner can look at the wallpaper monitor and answer, without opening a
terminal: which host/card is active, how much power each card draws, whether
both testbench 3090s are visible, and whether the remote reading is current.

```pbc:grounding
id: GPUWM-GROUND-001
source: /home/blueaz/.config/waybar/sysinfo.sh
observed: The screenshot shows the actual wallpaper overlay (`SYSTEM`, `GPU`,
  `SCREEN 3`) supplied by config-overlay. The terminal popup is the wrong
  surface and must not be extended.
```
