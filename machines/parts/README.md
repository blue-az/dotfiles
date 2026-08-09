# PC Parts Inventory

Hardware inventory for built systems and the spare-parts shelf, so the desktop's
spec and the backup parts list stop living in a build video.

Follows the same idea as `keyboards/<name>/README.md`, but one file — parts are
only interesting relative to each other (socket, wattage, clearance).

**Every row carries a source.** `build spec` = the "PC Build Specs — August 2019
build" page from the build video, transcribed 2026-08-09; the most authoritative
source here. `repo` = documented elsewhere in this repo and verified.
`reported` = stated by Erik, model not yet recorded. `TODO` = unknown. Do not upgrade a `reported` or
`TODO` row to a specific model without checking the actual hardware or invoice —
guessing here produces exactly the incompatibility this file exists to prevent.

---

## System 1 — Desktop (built, in service)

Dual-boots Fedora 43 (Sway) and Windows 11 on the same hardware.

| Part | Spec | Source |
|---|---|---|
Originally built **August 2019**; the GPU and RAM have since been replaced.

| Part | Spec | Source |
|---|---|---|
| Case | Fractal Design Define R6 USB-C, Black Brushed Aluminum/Steel, ATX Silent Modular Mid Tower — 7 rear expansion slots, run **open** (no side panel) | build spec |
| Motherboard | MSI MPG Z390 Gaming Plus, **LGA1151** | build spec |
| CPU | Intel Core i9-9900KF Coffee Lake, 8C/16T, 3.6 GHz base / 5.00 GHz — **no integrated graphics** ("KF") | build spec |
| CPU cooler | Scythe Ninja 5 (large fin-stack tower) | build spec |
| RAM | **Currently 32 GB.** Ran 64 GB across 4 sticks; **two died in the PSU incident** and were pulled, landing it back on the TEAMGROUP Elite DDR4 2x16GB 3200MHz the 2019 spec lists. The dead sticks were first mistaken for a blown motherboard — the board is fine. A replacement stick/kit arrives **2026-08-10**. Original Corsair Vengeance LPX 16GB (2x8GB) predates all of this. `machine-overview.md`'s `62.72 GiB` is a pre-failure snapshot. | build spec / reported |
| GPU 1 | Zotac RTX 3090 Trinity — 2.5-slot (58mm), 292–320mm, native slots 2-3 | repo |
| GPU 2 | EVGA RTX 3090 XC3 — 2.2-slot (48mm), 285mm — mounting unresolved, see `machines/desktop/ISSUES.md` | repo |
| GPU (original) | ASUS ROG STRIX GeForce RTX 2080 Overclocked 8G GDDR6 — displaced by the 3090, now on the shelf | build spec |
| PSU | ⚠️ **The Corsair HXi HX750i, 750W BLEW — it is dead, not shelf stock.** What is in the desktop now is unrecorded. See the warning below. | build spec / reported |
| Storage | **Samsung 970 EVO 1TB NVMe SSD.** The 488 GiB btrfs root is Fedora's share; the rest is the Windows 11 side of the dual boot. | build spec |
| Network | `eno1` (onboard ethernet) | repo |
| Displays | Acer Predator XB271HU 2560x1440@144 (165 OC) · Acer AL2216W 1680x1050@60 · LG TV 1920x1080@60 | repo |

Sag support: Zotac uses an upHere G195BK; the EVGA is planned to sit on a cut
wood dowel. The Zotac's fans already suffered real sag damage — do not reinstall
it unsupported.

### The PSU failure, and what replaced it

**2026-07-27** — the Corsair HX750i "popped loudly and expelled gas thru vent.
Dead after." Originally bought from Amazon.

**Corsair RMA #2009087410** (ticket opened 2026-07-27, warranty exchange approved
**2026-07-29, valid 30 days**). The HX750i is out of stock, so Corsair offered and
Erik accepted an alternate model:

| | |
|---|---|
| Warranty replacement | **Corsair RMx Series RM1000x, 1000W, fully modular** — part `CP-9020271-NA` |
| Interim unit | 850W (model unrecorded) — **approved for temporary use**, currently running System 1 |
| Return tracking | UPS `1Z966E659098549741`, prepaid label |
| Replacement ships | only *after* Corsair receives the dead unit |

> ⏳ **The 30-day RMA window closes around 2026-08-28.** The replacement does not
> ship until the return arrives, so if the dead HX750i has not gone out yet, that
> is the clock to watch.

**Knock-on effects:**

1. **Phase 1 of the quad-rig plan is blocked** — it specifies "existing 750W PSU
   with power capping (`nvidia-smi -pl 200`/`250`, ~500–550W total)". That budget
   was sized against a unit that no longer exists and must be re-derived. The
   1000W replacement is *more* headroom than the plan assumed, which is good news
   for dual-3090 testing once it lands.
2. **The 850W may become System 2's PSU.** It is described as temporary, so once
   the RM1000x arrives it should free up — which is a large part of why the second
   build is suddenly close. Confirm rather than assume.
3. **The motherboard is cleared.** It was initially suspected blown; the actual
   casualties were RAM sticks. See the RAM row.

---

## Shelf — backup parts (available for System 2)

| Part | Have | Model | Source |
|---|---|---|---|
| PSU | yes | TODO — **wattage is the load-bearing number**, record it first | reported |
| Motherboard | yes | TODO — **socket + chipset determine the CPU and the cooler**, record before shopping | reported |
| CPU cooler | yes | TODO — record socket compatibility, not just the model | reported |
| RAM | yes | TODO — DDR generation must match the spare board | reported |
| GPU | yes | **ASUS ROG STRIX GeForce RTX 2080 Overclocked 8G GDDR6** — ~300mm, ~2.7-slot. System 1's original card, displaced by the 3090; also served as the 3090 clearance test-fit dummy | build spec |

**Naming settled: it is an RTX 2080, not a 2080 Super.** The build spec reads
"GeForce RTX 2080 Overclocked 8G GDDR6" — 2080 is the die; OC is ASUS's factory
overclock on that die. Super is a different die entirely. Earlier references to
an "RTX 2080 Super" in `machines/desktop/ISSUES.md` were a conflation and have
been corrected. Call it **RTX 2080** in any future note.

### Open question: are the shelf parts duplicates, or displaced upgrades?

The August 2019 build spec covers System 1, and its PSU, board, cooler, and case
are all **still in service** — so it does not by itself identify the shelf.
Two possibilities, and they lead to very different System 2 builds:

- **Displaced by upgrades** — like the 2080 and the older RAM kits. This fits
  RAM cleanly (two kits have been superseded), but nothing in the repo shows the
  board, PSU, or cooler ever being replaced.
- **A genuinely separate set** from another machine, unrelated to this build.

Until that is settled, the four shelf `TODO`s below cannot be filled from the
2019 spec — they need a look at the actual shelf.

---

## System 2 — second desktop from backup parts (not built)

> ### ⛔ Gated on the RM1000x — not immediate, and not urgent
>
> System 2's PSU is the **850W currently running System 1 on approved temporary
> use**. It cannot move until the warranty RM1000x arrives and takes over. So
> System 2 does not start when the parts are gathered — it starts when that
> replacement lands. No rush; this is a scoping exercise, not a build queue.

**Design target: minimum viable, must still drive a 3090.** Deliberately scoped
to the low end rather than balanced — the 3090 does the work, everything else
just has to not get in its way.

| # | Part | Status | Spec | Notes |
|---|---|---|---|---|
| 1 | PSU | gated | **850W** (model TODO) | Ample for one 3090. Frees up only when the RM1000x lands. |
| 2 | Motherboard | on shelf | **Same as System 1** — MSI MPG Z390 Gaming Plus class, **LGA1151** | Reported as identical; verify the exact board before buying a CPU against it. |
| 3 | CPU cooler | on shelf | **65W TDP rated** | ⚠️ **This is the binding constraint on part 6.** |
| 4 | RAM | on shelf | **16 GB max** | Ceiling is the plan, not the board — Z390 takes far more if it ever needs to. |
| 5 | Case | **deferred** | — | Not being specified. ~$40 units are available, but the preference is to ship the parts and let whoever receives it choose. |
| 6 | CPU | **to buy** | LGA1151, **≤65W TDP** | See shortlist below. |
| 7 | HDD | **to buy** | whatever is on hand, else cheapest | Upgrade later. An SSD is still the single biggest felt-speed difference if the cheap option is close in price. |

### The 65W ceiling drives the CPU choice

The cooler caps CPU TDP at 65W, which **rules out the K-series entirely** — the
9900KF in System 1 is 95W. On LGA1151 that leaves the non-K Coffee Lake parts,
all 65W:

| CPU | Cores | iGPU | Fit for "drives a 3090" |
|---|---|---|---|
| i3-9100F | 4C/4T | none | Cheapest that works. Will bottleneck a 3090 in CPU-bound work. |
| **i5-9400F** | 6C/6T | none | The usual budget-3090 pairing. Best value on the min end. |
| i7-9700F | 8C/8T | none | Comfortable headroom, still 65W. |
| i9-9900 | 8C/16T | none | Same silicon class as System 1's 9900KF at 65W instead of 95W. Priciest. |

**Prefer an `F` part.** No integrated graphics is fine here — a 3090 is always
present — and F chips are cheaper for identical compute. Confirm the board's
BIOS supports 9th gen before buying; Z390 generally does out of the box.

### Consequences of the min-end scope worth knowing

- **16 GB with a 3090 is fine for display, gaming, and inference** where the
  model lives in the card's 24 GB. It is **tight for anything that stages
  through system RAM** — dataset prep, large model loading/conversion, or
  multi-GPU work. If System 2 is ever meant to do AI work rather than drive a
  display, this is the first ceiling it hits, not the CPU.
- **Three GPUs, two systems.** Assigning a 3090 to System 2 means System 1 runs
  one 3090 plus the 2080 rather than dual 3090s — which is in tension with
  Phase 1 of the quad-rig plan. Worth deciding explicitly rather than by
  whichever build happens first.
- **Case deferred is fine, but the 3090 sets a floor.** Both 3090s are ~292–320mm
  and 2.2–2.5 slots. A $40 case will fit that only if it is a mid-tower; whoever
  picks needs that number, not a free choice.

---

## How to fill this in

The four shelf models exist only in a build video right now. Watch it **once**
and replace the four `TODO`s in the System 2 table — after that this file is the
source and the video is retired.

Priority order, because part 2 unblocks parts 3, 4, and 6:

1. Motherboard — socket and chipset
2. PSU — wattage and PCIe connectors
3. RAM — DDR generation and capacity
4. Cooler — supported sockets

Faster alternatives to watching it, if either applies:

- **The video is online with a parts list in its description** (or links a
  PCPartPicker build) — paste the URL and the list can be pulled from the page
  directly, no watching required.
- **The board is reachable** — if the spare board is installed in anything that
  boots, `sudo dmidecode -t baseboard -t memory` prints the board model and the
  full RAM spec with no video at all.

If neither applies, the physical labels work: board model is silkscreened
between the PCIe slots, PSU wattage is on the side sticker, RAM timings are on
the stick label.
