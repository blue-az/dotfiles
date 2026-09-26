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
hardware. Two surfaces show the `testbench` GPUs: the wallpaper overlay Waybar
instance (`~/.config/waybar/config-overlay` + `~/.config/waybar/sysinfo.sh`) for
detail, and the compact monitor bar module (`config-monitor` +
`scripts/monitor.sh`) for utilization at a glance. Not a terminal popup.

Revised 2026-09-26 (owner decision): both surfaces are testbench-only. The
desktop GPU is no longer shown, and the compact bar module may change. The
original 2026-09-11 draft kept the bar module unchanged and showed the desktop
and testbench GPUs together; that is superseded.

## Scope

- Both surfaces show the remote headless `testbench` GPUs; the desktop GPU is
  not shown.
- The headless testbench currently has two RTX 3090 cards; both cards must be
  represented independently, not summed into one number.
- Use the existing dashboard visual language and continuously update without
  terminal repaint flashes or popup-window focus behavior.
- Show, when available, per GPU: host, GPU name, utilization, temperature,
  power draw, power limit, memory used/total, and active model/process context.
- Label the surface as `testbench` (overlay title `HEADLESS MONITOR`) and
  identify each card by a stable label (PCI bus ID or GPU index plus name).

## Non-goals

- Do not redesign Waybar beyond these two modules.
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

Implemented in dotfiles `f5e67d8`, plus the `n/a` fix that follows it:

- Done: both surfaces read both testbench cards over SSH with a 2 s timeout;
  the overlay title reads `HEADLESS MONITOR`; the overlay shows name,
  utilization, temperature, power and memory per card and `TB GPU unavailable`
  when the testbench is unreachable; the bar shows `n/a` per card instead of
  `0%` when a reading is missing.
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
