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
| Interim unit | 850W (model unrecorded — not identifiable from Gmail) |
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

**A complete build is 7 parts.** Four are on the shelf, three are not. This table
is the whole list — it should never be necessary to watch the build video again
once the Model column is filled.

| # | Part | Status | Model | Notes |
|---|---|---|---|---|
| 1 | PSU | likely covered | 850W (model TODO) | The interim unit should free up when the warranty RM1000x lands. Confirm before counting on it. |
| 2 | Motherboard | on shelf | TODO | **Record this first.** Socket + chipset decide parts 5 and 6. |
| 3 | CPU cooler | on shelf | TODO | Must mount the same socket as the board. |
| 4 | RAM | on shelf | TODO | DDR generation must match the board. |
| 5 | Case | **to buy** | — | Only needs slot count / GPU length if the 2080 OC goes in (~300mm, 2.7 slots — large for a small case). |
| 6 | CPU | **to buy** | — | **Not a free choice** — the board's socket decides the shortlist. Same LGA1151 era as the 9900KF means a cheap used market. |
| 7 | HDD | **to buy** | — | Consider an SSD for boot regardless of the slot's name; biggest felt-speed difference on an older build, negligible cost at small capacities. |

A GPU is not in the seven — **there are three cards for two systems** (Zotac
3090, EVGA 3090 XC3, ASUS 2080), so System 2 is covered with one to spare. Note
part 6 though: if the CPU chosen has no integrated graphics (like the 9900KF),
that GPU is **required** for the machine to POST at all, not optional.

**Status as of 2026-08-09:** the gap has narrowed to **case, CPU, and HDD**.
PSU is likely covered by the freed 850W, RAM by the 2026-08-10 delivery, GPU by
the spare 2080, and cooler/board were already on the shelf. Also inbound: a
"65W fan" (as described — exact part unrecorded).

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
