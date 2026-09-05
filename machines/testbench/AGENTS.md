# Test Bench Guidelines

> **Directory name is provisional.** Created 2026-09-04 before the hostname was
> confirmed. If Debian was installed under a different hostname, rename this
> directory to match and update `machines/machine-overview.md`.

## Agent Terminology
- **BN = Bottlenecks**: in prompts and docs, **BN** means bottlenecks — friction
  points, issue tracking in `ISSUES.md`, and their resolution.

## Machine Overview

- Host: open-air bench build on a **W01 DIY test bench frame**, Debian.
- Referred to as **"System 2"** in `machines/parts/README.md`, which holds the
  authoritative component list and the compatibility chain.
- Built 2026-09-04. Build log and the gotchas found during bring-up:
  [`BUILD_HANDOFF.md`](BUILD_HANDOFF.md).

**This machine exists for two jobs:**

1. **Validate the Corsair RM1000x** — the warranty replacement for the HX750i
   that failed 2026-07-27. Validated here rather than in the desktop so a fault
   is isolated to a machine nothing depends on.
2. **Be the bench for RTX 3090 configuration work.** The desktop is
   mid-benchmark-program and must not be disturbed. Two machines means single-
   GPU and dual-GPU configurations can be held at the same time instead of
   toggling a systemd override on the only box.

## Hardware

| Part | Model |
|---|---|
| PSU | Corsair RM1000x, 1000 W, fully modular (`CP-9020271-NA`) |
| Board | MSI MPG Z390 Gaming Plus, LGA1151 — same board as the desktop |
| CPU | Intel i3-9100F, 4C/4T, 3.6 GHz, 65 W — **no integrated graphics** |
| Cooler | 65 W-rated LGA115x |
| RAM | Corsair Vengeance LPX 16 GB (2×8) DDR4-3200 — the desktop's original 2019 kit |
| Drive | Samsung PM981a 512 GB NVMe (`MZVLB512HBJQ`), OEM, no consumer warranty |
| GPU | **ASUS ROG STRIX RTX 2080 OC 8G** — installed 2026-09-04 |
| Frame | W01 open-air bench, 2-pin momentary switch included |

**Deliberately minimum-viable.** The GPU does the work; everything else only has
to not get in its way. The 16 GB ceiling is the RAM kit itself, not a board or
plan limit.

## Stow Packages & Linking

Goal: keep it close to the Fedora desktop workflow while leaving the OS Debian.
Use the Debian sway package, not the Fedora one.

```bash
cd ~/.dotfiles
stow --no-folding apps bash sway-debian waybar i3 shared nvim xkb wallpaper
mkdir -p ~/.config/sway/config.d
ln -sf outputs.conf.testbench ~/.config/sway/config.d/outputs.conf
```

`--no-folding` keeps `~/.config/sway` as a real directory, so the per-machine
`outputs.conf` pointer stays local instead of rewriting tracked files inside the
repo. Validate with `ls -ld ~/.config/sway`: a directory is correct, a symlink is
not.

The test bench output template is intentionally generic until the actual NVIDIA
connector names are recorded from the installed OS:
`sway-debian/.config/sway/config.d/outputs.conf.testbench`.

## Things that are true of this machine and not the desktop

- **No integrated graphics.** The i3-9100F is an F-series part. The board's video
  ports are permanently dead. A black screen with no card installed is a
  *successful* POST, not a failure. Never diagnose display problems here without
  a card seated.
- **No onboard WiFi.** The Gaming Plus has none. The AIC8800 USB adapter **does
  work** (proven on Debian 12 / kernel 6.1) but only via an out-of-tree DKMS
  driver with a hard kernel ceiling — see `ISSUES.md`. **Keep wired ethernet as
  the recovery path.**
- **Open air, no case.** Nothing braces the GPU; a ~300 mm card needs support.
  Nothing filters dust. Nothing stops a dropped screwdriver.
- **Power switch is a bare 2-pin momentary** on `JFP1`. There is no case power
  LED — the GPU's own lighting is the only visual indicator that it is running.

## Before diagnosing anything hardware-shaped

Read the gotcha list in [`BUILD_HANDOFF.md`](BUILD_HANDOFF.md) first. Nearly
every symptom during bring-up looked like a failed component and was not — a
silent PSU, a dark board, a CPU↔DRAM debug-LED loop, and a black screen were all
normal behaviour or dirty contacts.
