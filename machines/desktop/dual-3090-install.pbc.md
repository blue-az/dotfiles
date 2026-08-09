---
id: dual-3090-install
title: "Dual RTX 3090 Physical Installation — Technical Drawing Set"
context: hardware-drafting
status: draft
updated: 2026-07-24
tags:
  - first-principles-rebuild
  - prior-attempts-failed
---

# Dual RTX 3090 Physical Installation — Technical Drawing Set

**Read this before doing anything else: two prior agents (Claude and Antigravity/Agy),
across ten-plus rounds, repeatedly drew the PCIe riser cable as if it could shrink,
taper, or twist. It cannot. This is the single most-violated rule in this whole
project and the reason this brief exists — treat it as load-bearing, not a style
note.**

## Hard physical rules (non-negotiable, checked first on any review)

1. A flat ribbon PCIe riser cable has a **constant width, equal to the connector
   it plugs into (89mm), for its entire length.** It does not taper, narrow, widen,
   or shrink anywhere along its run.
2. It **bends within one flat plane only. It cannot twist** (rotate about its own
   long axis). Any apparent rotation in the drawing happens inside the small rigid
   connector-housing part at one end, never in the flexible ribbon itself.
3. A card's **rear I/O bracket is a rigid plate screwed into the case's fixed rear
   panel.** There is no depth freedom at any slot position — every slot sits at the
   same depth, differing only in vertical (slot-row) position. A riser cable changes
   which slot-row a card connects to; it never lets a card sit at a different depth
   than a direct-mounted card would.
4. A graphics card has **three independent physical dimensions**, and each belongs
   to a different drawing:
   - **Length** (front-to-back into the case) — belongs in a side/profile view.
   - **Slot-thickness** (vertical, "2.5-slot" etc. — how many rear-bracket slot
     positions the cooler physically occupies) — belongs in both side and rear views.
   - **Height / PCB-width** (side-to-side, the axis the connector's own 89mm length
     runs along) — belongs ONLY in a rear view or a dedicated connector-detail view.
     **Never draw this dimension, or the connector/cable's width, inside a side
     view** — that was the single most repeated error across every prior attempt.

## Sourced dimensions — use only these numbers; do not invent or re-derive others

| Component | Length | Slot-thickness | Height/PCB-width | Source |
|---|---|---|---|---|
| Zotac RTX 3090 Trinity (installed, slots 2-3) | 292–320mm | 58mm (2.5-slot) | 120mm | ZOTAC product page / ServeTheHome |
| EVGA RTX 3090 XC3 (incoming, slots 6-7 via riser) | 285mm | 48mm (2.2-slot) | 111.15mm | TechPowerUp / EVGA spec page |
| PCIe x16 connector | — | — | 89mm long × 6.5mm deep | PCI-SIG standard |
| ATX slot pitch | — | 20.32mm between adjacent slots | — | ATX/PCI bracket standard |
| OwlTree PCIe 4.0 x16 riser | 200mm flexible length | — | 89mm constant width, 90° adapter at card end only | product listing |
| Case / board / cooler | Fractal Design Define R6 (7 rear slots) / MSI MPG Z390 Gaming Plus / Scythe Ninja 5 (large fin-stack tower, not a fan icon) | | | this session |
| ASUS ROG STRIX RTX 2080 OC (**now part of the final build** — vertical, paired with the EVGA; was originally the test-fit dummy) | ~300mm | ~65mm (2.7-slot) | ~120mm ESTIMATE, not sourced | prior test-fit |

Measured real clearances (physically test-fit this session, more reliable than
formula-derived estimates): **~30mm** between the two cards' cooler shrouds;
**~16-20mm** between the EVGA and the PSU shroud below it.

**Verified physically 2026-08-09: the 2080 + EVGA 3090 pairing fits BETTER in
this case than two 3090s do — despite the 2080 being the thicker card on paper
(~2.7 slot vs the Zotac's 2.5).** This is a real quirk of these specific cards in
this specific case, confirmed by test-fit, not a measurement error. Do not
"correct" it by re-deriving from slot-thickness numbers; the numbers predict the
opposite and the numbers are wrong here. Same rule as the riser-cable geometry
above — physical fit is load-bearing, spec arithmetic is not.

## Topology (the physical layout to draw)

**UPDATED 2026-07-24 after real hardware inspection — supersedes the original
flat-riser slots-6-7 plan.** Two facts changed by physical examination: the
motherboard's second physical x16 slot sits **3 slot-rows below the first, not 2**,
and a flat ribbon riser **cannot be mechanically anchored** between the native slot
and a lower bracket position (nothing rigid to fasten at the card end). The
horizontal-relocation plan is therefore not viable as originally drawn.

**PRIORITY UPDATED 2026-07-24 (evening): vertical mount is now the CURRENT/PRIMARY
plan; the horizontal swap-stack is the fallback.** Plan labels below retain their
letters but B is primary, A is fallback.

**Plan A (fallback): SWAP the cards, then stack horizontally, run hot.**
The thinner EVGA (2.2-slot) goes ON TOP in the first x16 slot (slots 2-3 position);
the Zotac (2.5-slot) moves to the second physical slot, 3 rows down. This order is
load-bearing, not cosmetic: 3-row pitch = 60.96mm; with the 2.2-slot EVGA on top the
inter-card clearance is ~0.8 slot (~16mm, Erik's own measured figure); with the
2.5-slot Zotac on top it would be only ~3mm — physically unworkable. Accepted
thermal cost, no new mounting hardware. Fallback if thermals prove unacceptable
under real measured load: sell the Zotac.

**Plan B (CURRENT/PRIMARY): vertical mount for the EVGA, direct-riser connection.**
The Zotac stays in its normal first-slot horizontal position (no swap needed). Thermaltake PCI-E 4.0
Dual 90° Riser Cable 400mm (AC-077-CO1OTN-C1 black / AC-077-CO6OTN-C1 Snow; sold out
direct, in stock at Newegg ~$65 as of 2026-07-24; **cable only — includes no
standoffs or bracket, confirmed**) + DIY support: generic M3 nylon standoffs (~$8
assortment) screwed into the PSU shroud's existing threaded holes (confirmed present
via installation video). The case has 2 dedicated vertical slot cutouts ("7+2"
per Fractal's own spec); the official VRC-25 kit is not practically obtainable
(Amazon listing showed $8.99/Define R6 but was actually out of stock). Both of the
VRC-25's rigid connector-end boards use standard slot-bracket profiles — vertical
mounting needs no proprietary rear-panel hardware, just the rigid 90° housing at the
card end tied down to the standoffs; the motherboard end plugs in straight. Erik
runs the case open (no side panel), which removes glass-clearance constraints and
most vendor-kit-specific dimensioning concerns.

**Power (both plans):** each card needs 2x 8-pin PCIe (4 connectors total, no
12VHPWR). Tight routing may need right-angle 8-pin adapters ("outward conversion"
type) — a normal, cheap product category.

Both cards' fans face into the shared inter-card gap in plan A — that's the
thermally important clearance, more than the PSU-side one. A support brace for the
Zotac (upHere G195BK, sliding clamp on a fixed pole) must be positioned clear of the
EVGA's own footprint. A cut wood dowel supports the EVGA in its tight PSU-side gap
(plan A) — plan B replaces the dowel with the standoff mount itself.

## Required drawings

1. **Side/profile view** — card length + slot-thickness only, both cards, correct
   topology above. Connectors are thin tick marks here, nothing wider.
2. **Rear panel view** — slot position + real height/width (120mm/111.15mm), with
   the motherboard structure visible, not floating brackets in empty space.
3. **Front/open-case view** — head-on fan faces, true relative slot-thickness,
   the ~30mm gap, the Scythe Ninja 5 as a real heatsink body (not a fan icon).
4. **Dedicated cable/connector detail view** — the riser cable and both its
   connector ends, zoomed in, on whichever plane actually contains its real 89mm
   width — showing the constant-width, no-taper, no-twist rule directly.

## Verification

Before treating any of this as done: check the file's own coordinates directly
(don't trust a chat summary of what was drawn). Confirm arithmetic — do stated
gaps/clearances actually equal the difference between the coordinates used? Confirm
no dimension outside the sourced table above appears anywhere.
