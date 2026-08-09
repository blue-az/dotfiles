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

> ### ⛔ Two gates, both upstream — not immediate, and not urgent
>
> System 2 needs **two** things to fall, and neither is about acquiring parts:
>
> 1. **The RM1000x lands.** System 2's PSU is the 850W currently running
>    System 1 on approved temporary use. It only frees up when the warranty
>    replacement takes over.
> 2. **The dual-3090 benchmark completes.** System 2's GPU — expected to be the
>    Zotac — stays in System 1 until the dual numbers are captured. The
>    benchmark may also change *which* card System 2 gets; see the allocation
>    branch below.
>
> The benchmark is **not** gated on the RM1000x — 850W is more headroom than the
> ~500–550W the original plan budgeted against a 750W unit. Nor is it blocked on
> mounting any more: as of 2026-08-09 a different riser cable plus a 180° power
> connector runs two cards in the existing case, horizontal + vertical. No rush
> on any of it; this is a scoping exercise, not a build queue.

**Design target: minimum viable, must still drive a 3090.** Deliberately scoped
to the low end rather than balanced — the 3090 does the work, everything else
just has to not get in its way.

| # | Part | Status | Spec | Notes |
|---|---|---|---|---|
| 1 | PSU | gated | **850W** (model TODO) | Ample for one 3090. Frees up only when the RM1000x lands. |
| 2 | Motherboard | arrives 2026-08-10 | **MSI MPG Z390 Gaming Plus, LGA1151** — same board as System 1 | Confirmed against the 2019 build spec. Validates the whole chain below. |
| 3 | CPU cooler | on shelf | **65W TDP rated** | ⚠️ **This is the binding constraint on part 6.** |
| 4 | RAM | on shelf | **16 GB max** | Ceiling is the plan, not the board — Z390 takes far more if it ever needs to. |
| 5 | Case | **deferred (decided 2026-08-09)** | none for now | Runs open-air. Budget **~$5 for a bench power button**, or jumper the `PWR_SW` header. Revisit only if System 1 gets a roomier case and the Define R6 becomes available as a hand-me-down. |
| 6 | CPU | **bought 2026-08-09** | **Intel i3-9100F** `SRF6N` — 4C/4T, 3.6 GHz, 65W, **no iGPU**. $17.99 used, kcliquidation (99.8%, 22.9K) | Meets the 65W ceiling. Weakest of the shortlist: fine GPU-bound, bottlenecks CPU-bound work. Accepted trade at the price. **No integrated graphics — this machine cannot produce video without a card installed.** |
| 7 | Drive | **bought 2026-08-09** | **Samsung PM981a 512 GB NVMe** (`MZVLB512HBJQ`), used | OEM sibling of System 1's 970 EVO — same M.2 2280 / PCIe 3.0 x4 class, half the capacity. OEM means **no consumer warranty**. Check SMART on arrival (`smartctl -a`): Power On Hours and Percentage Used. Still the wrong size if System 2 ever does inference. |

### Compatibility chain — validated 2026-08-09

With the board confirmed as the same MSI MPG Z390 Gaming Plus (LGA1151) as
System 1, every downstream part checks out:

| Link | Status |
|---|---|
| Board socket → CPU | LGA1151 ↔ i3-9100F ✅ |
| Chipset → CPU generation | Z390 launched alongside 9th gen ✅ (a very early BIOS may still want a flash — System 1's 9900KF is the same socket, so there is no chicken-and-egg risk) |
| Board → RAM | DDR4 ✅ |
| Board → SSD | Z390 has M.2; PM981a is M.2 2280 PCIe 3.0 x4 ✅ |
| Board → GPU | PCIe 3.0 x16 ✅ |
| Cooler → socket | 65W unit must have LGA1151 mounting — **the one link still unverified**; confirm when it goes on |

### The 65W ceiling drives the CPU choice

The cooler caps CPU TDP at 65W, which **rules out the K-series entirely** — the
9900KF in System 1 is 95W. On LGA1151 that leaves the non-K Coffee Lake parts,
all 65W:

| CPU | Cores | iGPU | Fit for "drives a 3090" |
|---|---|---|---|
| **i3-9100F ← chosen** | 4C/4T | none | Cheapest that works, ~$20 and plentiful. Will bottleneck a 3090 in CPU-bound work; fine when the GPU is doing the job. |
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
- **GPU allocation, and the branch that decides it.** System 1 can now run two
  cards in its existing case — one horizontal, one vertical — via a different
  riser cable plus a 180° power connector. So the sequence is:
  1. **Benchmark dual 3090s first** (one horizontal, one vertical). This gates
     everything.
  2. **If the split proceeds:** System 1 keeps the **EVGA 3090 horizontal + the
     ASUS 2080 vertical**; the **Zotac 3090 goes to System 2**.
  3. **If dual performance wins**, the split does not happen — System 1 keeps
     both 3090s and **System 2 gets the 2080 instead**. That changes System 2's
     scope below: a 2080 is a ~215W card against the 3090's ~350W, so the
     "must drive a 3090" sizing becomes generous rather than minimum.
- **Case deferred is fine, but the 3090 sets a floor.** Both 3090s are ~292–320mm
  and 2.2–2.5 slots. A $40 case will fit that only if it is a mid-tower; whoever
  picks needs that number, not a free choice.

### Inbound / status as of 2026-08-09

| Item | Status | For |
|---|---|---|
| RAM (16 GB) | **in hand** | System 2 |
| 65W-TDP cooler | **in hand** | System 2 — sets the CPU ceiling |
| Thermal paste | arrives 2026-08-09 | Cooler mount; reseating anything disturbed in the EVGA install |
| Motherboard | arrives **2026-08-10** | System 2 — **record the exact model on arrival**, it is still a TODO above |
| CPU (i3-9100F, used) | **~1 week out** | System 2 |
| NVMe SSD (Samsung PM981a 512 GB, used) | **~1 week out** | System 2 |
| PSU (Corsair RM1000x) | ⚠️ **not started** — dead unit not yet shipped back | System 1; frees the 850W for System 2 |

> ### ⏰ The RMA return is the only hard deadline in this project
>
> The dead HX750i **has not been sent back yet**. Nothing ships from Corsair
> until they receive it, and the approved window closes **~2026-08-28** — about
> 19 days out. Everything else here can slip indefinitely at no cost; this one
> expires and cannot be restarted. It is also the gate on System 2's PSU, so a
> missed window stalls both machines.

> ### ⏰ Test the used parts before their return windows close
>
> The CPU and SSD are used eBay purchases arriving ~2026-08-16, so their return
> windows likely close ~mid-September. System 2 cannot be powered on until the
> 850W frees up, which depends on an RMA that has not started — so on the
> current path **both parts sit untested until well after they can be returned**.
>
> Fix: bench-test them early rather than waiting. Pull the 850W from System 1
> briefly, boot the new board bare (CPU + cooler + one RAM stick + SSD), confirm
> POST and that the drive is detected, then put it back. An hour's work that
> converts unverifiable used parts into known-good ones while there is still
> recourse. Check SMART on the PM981a in the same sitting.
>
> **The 9100F has no integrated graphics, so this test needs a card.** Two
> levels, depending on how much disruption is acceptable:
>
> - **No GPU needed:** power on and watch the board's EZ Debug LEDs step past
>   CPU and DRAM. That alone proves the used CPU and the RAM are alive — enough
>   to act on a return.
> - **GPU needed:** to reach BIOS and confirm the SSD is detected, borrow a card.
>   The ASUS 2080 is the one to grab if it is out of System 1 at the time; it is
>   the least disruptive of the three to pull and reseat.

---

## Remaining unknowns

**The video is retired.** Its build-spec page is transcribed into System 1 above,
and it also settled System 2's board — the blocking unknown that decided the CPU,
RAM, and cooler. Nothing further needs to be watched.

What is left is cosmetic rather than blocking:

| Unknown | Blocks anything? | How to close it |
|---|---|---|
| Interim 850W PSU — exact model | No. Wattage is what matters and it is known | Side sticker |
| RAM — exact kit/timings | No. 16 GB DDR4 is enough to plan against | Stick label, or `sudo dmidecode -t memory` once it boots |
| 65W cooler — model and socket support | **Mounting only** — must be LGA1151 | Box or the bracket set in hand |
| Riser cable + 180° power connector | No, but the working dual config is not reproducible without it | Record at install |

Once System 2 boots, `sudo dmidecode -t baseboard -t memory` prints the board and
the full RAM spec in one shot and closes two of these for free.
