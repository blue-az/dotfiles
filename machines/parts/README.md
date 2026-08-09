# PC Parts Inventory

Hardware inventory for built systems and the spare-parts shelf, so the desktop's
spec and the backup parts list stop living in a build video.

Follows the same idea as `keyboards/<name>/README.md`, but one file — parts are
only interesting relative to each other (socket, wattage, clearance).

**Every row carries a source.** `repo` = already documented elsewhere in this
repo and verified. `reported` = stated by Erik, model not yet recorded.
`TODO` = unknown, fill from the build video. Do not upgrade a `reported` or
`TODO` row to a specific model without checking the actual hardware or invoice —
guessing here produces exactly the incompatibility this file exists to prevent.

---

## System 1 — Desktop (built, in service)

Dual-boots Fedora 43 (Sway) and Windows 11 on the same hardware.

| Part | Spec | Source |
|---|---|---|
| Case | Fractal Design Define R6 — 7 rear expansion slots, run **open** (no side panel) | repo |
| Motherboard | MSI MPG Z390 Gaming Plus | repo |
| CPU | Intel Core i9-9900KF, 8C/16T @ 5.00 GHz — **no integrated graphics** ("KF") | repo |
| CPU cooler | Scythe Ninja 5 (large fin-stack tower) | repo |
| RAM | 64 GB (reports 62.72 GiB) — speed/kit/slot layout unrecorded | repo / TODO |
| GPU 1 | Zotac RTX 3090 Trinity — 2.5-slot (58mm), 292–320mm, native slots 2-3 | repo |
| GPU 2 | EVGA RTX 3090 XC3 — 2.2-slot (48mm), 285mm — mounting unresolved, see `machines/desktop/ISSUES.md` | repo |
| PSU | 750W — model unrecorded. Drives the dual-3090 power capping (`nvidia-smi -pl 200`/`250`, ~500–550W total) | repo / TODO |
| Storage | 488 GiB root, btrfs — physical drive model/count unrecorded | repo / TODO |
| Network | `eno1` (onboard ethernet) | repo |
| Displays | Acer Predator XB271HU 2560x1440@144 (165 OC) · Acer AL2216W 1680x1050@60 · LG TV 1920x1080@60 | repo |

Sag support: Zotac uses an upHere G195BK; the EVGA is planned to sit on a cut
wood dowel. The Zotac's fans already suffered real sag damage — do not reinstall
it unsupported.

---

## Shelf — backup parts (available for System 2)

| Part | Have | Model | Source |
|---|---|---|---|
| PSU | yes | TODO — **wattage is the load-bearing number**, record it first | reported |
| Motherboard | yes | TODO — **socket + chipset determine the CPU and the cooler**, record before shopping | reported |
| CPU cooler | yes | TODO — record socket compatibility, not just the model | reported |
| RAM | yes | TODO — DDR generation must match the spare board | reported |
| GPU | yes | ASUS ROG STRIX RTX 2080 OC — ~300mm, ~2.7-slot. Used as the 3090 clearance test-fit dummy, explicitly "not part of the final build" | repo |

Naming discrepancy to settle: `machines/desktop/ISSUES.md` Phase 2 says "swap
**RTX 2080 Super** into desktop," while the drawing set says **RTX 2080 OC**.
Either that is two cards or one card described two ways — check the shelf.

---

## System 2 — second desktop from backup parts (not built)

Missing, per Erik:

| Part | Notes |
|---|---|
| **Case** | Slot count and GPU length only matter if the 2080 goes in — it is ~300mm and 2.7 slots, which is a large card for a small case. |
| **CPU** | **Constrained by the spare motherboard's socket, not chosen freely.** Record the board first; that decides the entire shortlist. If it is the same LGA1151 generation as the 9900KF, the used market for that era is cheap. |
| **HDD** | Consider an SSD for boot regardless of what the slot is called — no meaningful cost difference at small capacities, and it is the single biggest felt-speed difference on an older build. |

### Checks to run once the shelf models are recorded

1. **Socket chain** — spare board socket must match both the new CPU *and* the
   spare cooler's mounting bracket. A cooler that fits the 9900KF's LGA1151 will
   not mount on an AM4/AM5 board without the right kit.
2. **RAM generation** — spare RAM's DDR generation must match the spare board.
3. **PSU headroom** — the 2080 OC is a ~215W card; check the spare PSU's wattage
   and that it has the right PCIe power connectors for it.
4. **Display output** — if the new CPU has no integrated graphics (like the
   9900KF), System 2 *requires* the 2080 to POST to a display at all.

---

## How to fill this in

Watch the build video once, then replace every `TODO` above. The rows that
actually block the System 2 build, in priority order:

1. Spare motherboard — socket and chipset
2. Spare PSU — wattage and PCIe connectors
3. Spare RAM — DDR generation and capacity
4. Spare cooler — supported sockets
