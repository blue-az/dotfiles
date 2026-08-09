---
id: pbc-gpu-architecture-decision
title: "GPU Architecture — Decision Brief for Supervisor"
context: desktop-hardware
status: draft
updated: 2026-08-09
tags:
  - hardware
  - decision-required
  - local-llm
  - awaiting-evidence
---

# GPU Architecture — Decision Brief for Supervisor

**Date:** 2026-08-09
**Audience:** supervisor deciding GPU allocation across System 1 / System 2
**Repo:** `blue-az/dotfiles`
**Related:** [`machines/desktop/ISSUES.md`](ISSUES.md) · [`machines/desktop/dual-3090-install.pbc.md`](dual-3090-install.pbc.md) · [`machines/parts/README.md`](../parts/README.md)

This is a **decision brief awaiting one piece of evidence**, not a build plan. Three
RTX GPUs must be allocated across two machines. A benchmark that gates the choice
has not run. The purpose here is to fix the decision criteria **before** the numbers
arrive, so the result is not rationalized afterward.

The central finding is that the workload does not obviously justify the hardware:
**local LLM inference is ~2% of operator time.** The remaining 98% — gaming, video,
general compute — is served fully by the weakest card on hand.

---

## Scope

- Allocating three GPUs (2× RTX 3090, 1× RTX 2080) across System 1 (built) and
  System 2 (parts gathered, not assembled).
- Fixing the benchmark question that decides between candidate architectures.
- Recording hard platform constraints that bound every option.

## Non-goals

- The Quad 3090 roadmap (Phase 2/3 in `ISSUES.md`). Out of scope; unaffected.
- Case selection for System 2 — deliberately deferred.
- Re-litigating the physical mounting solution. Settled 2026-08-09: a riser plus
  180° power connector runs two cards in the existing Define R6, horizontal +
  vertical. Do not reopen.
- Model selection or fine-tuning strategy.

## Terms

| Term | Definition |
| --- | --- |
| TP | Tensor parallelism — splits individual tensors across GPUs; interconnect-heavy. |
| Layer split | Assigns whole layers per GPU (llama.cpp/Ollama); moves far less data. |
| PCH | Platform Controller Hub. Chipset-fed PCIe lanes, sharing one DMI uplink. |
| Offload box | A second machine holding heavy GPUs, normally suspended, woken on demand. |
| Mixed / hybrid | One 3090 + the 2080 in a single machine. |

```pbc:glossary
- term: TP
  definition: Tensor parallelism — splits individual tensors across GPUs; interconnect-heavy.
- term: Layer split
  definition: Assigns whole layers per GPU (llama.cpp/Ollama); moves far less data across the link.
- term: PCH
  definition: Platform Controller Hub. Chipset-fed PCIe lanes sharing a single DMI 3.0 uplink.
- term: Offload box
  definition: Second machine holding heavy GPUs, normally suspended, woken on demand.
- term: Mixed
  definition: One RTX 3090 plus the RTX 2080 in a single machine.
```

## Actors

```pbc:actors
- id: system_1
  name: Desktop (built, in service)
  type: machine
  description: MSI MPG Z390 Gaming Plus, i9-9900KF, 32GB, Fractal Define R6. Dual-boots Fedora and Windows.
- id: system_2
  name: Second build (not assembled)
  type: machine
  description: Duplicate Z390 board, i3-9100F, 16GB, Rosewill 850W. Case deferred, runs open-air.
- id: zotac
  name: Zotac RTX 3090 Trinity
  type: gpu
  description: 24GB, 2.5-slot, 292-320mm. Has prior sag-damaged fans; requires bracing.
- id: evga
  name: EVGA RTX 3090 XC3
  type: gpu
  description: 24GB, 2.2-slot, 285mm. Smaller cooler; expected to throttle sooner under sustained load.
- id: asus_2080
  name: ASUS ROG STRIX RTX 2080 OC
  type: gpu
  description: 8GB, ~2.7-slot, ~300mm. Turing (SM 7.5). System 1's original 2019 card.
```

## States

```pbc:states
- id: current
  name: Undecided — awaiting benchmark
  description: EVGA newly installed. Dual not yet benchmarked. Allocation unresolved.
- id: arch_a
  name: A — Single machine, mixed
  description: System 1 runs 2080 + one 3090. No offload box. Spare 3090 unallocated.
- id: arch_b
  name: B — Lean main plus dual offload
  description: Main box is 2080-only. System 2 holds both 3090s, suspended when idle.
- id: arch_c
  name: C — Lean main plus single offload
  description: Main box is 2080-only. System 2 holds one 3090. Second 3090 sold or redeployed.
```

## Rules

```pbc:rules
- id: interconnect_ceiling
  statement: The MSI MPG Z390 Gaming Plus runs x16/x4 with the second full-length slot fed by the PCH, not the CPU. Any second GPU gets PCIe 3.0 x4 sharing the DMI uplink with M.2, SATA, USB, and LAN.
  evidence: MSI specification; board is CrossFire-certified but not SLI-certified, which requires x8/x8.
  consequence: Applies to BOTH machines — the boards are duplicates. An offload box does not escape this.
- id: no_board_fix
  statement: The i9-9900KF exposes only 16 CPU PCIe lanes. No board-level remedy exists on this platform.
  consequence: This is precisely the constraint the Quad 3090 roadmap's EPYC (128 lanes) exists to remove.
- id: nvlink_is_the_only_lever
  statement: The RTX 3090 is the only consumer Ampere card with NVLink (~112 GB/s, bypassing PCIe). Approximately $80-150.
  consequence: Materially helps TP; helps layer-split workloads much less. Presence not yet confirmed via nvidia-smi topo -m.
- id: mismatched_pair_does_not_pool
  statement: A 3090 + 2080 pair yields no usable VRAM pooling. Turing lacks bf16; vLLM TP assumes homogeneous GPUs and would strand 16GB of the 3090; SLI is dead on Ampere.
  consequence: The hybrid is valuable for INDEPENDENT workloads on the 2080, not for pooled capacity.
- id: workload_reality
  statement: Local LLM inference is approximately 2% of operator time. Gaming, video, and general compute are fully served by the RTX 2080.
  consequence: Optimizing the daily driver around a 3090 pays cost 100% of the time for a 2% benefit.
- id: thermal_and_power_context
  statement: RTX 3090 draws ~350W under load versus the 2080's ~215W. Two 3090s is ~700W, plus roughly 200W of air conditioning to remove that heat in a Tempe, AZ climate.
  consequence: Mitigated almost entirely by suspending an offload box rather than by card choice.
```

## Behaviors

```pbc:behavior
- id: gating_benchmark
  name: The benchmark that decides the architecture
```
```pbc:preconditions
- EVGA 3090 physically installed alongside the Zotac (riser + 180° power connector).
- A PSU adequate for two 3090s under power cap. The interim Rosewill 850W satisfies this.
- Note which physical slot the vertical card occupies; if PCI_E4, that card is on x4.
```
```pbc:trigger
- Operator runs the capture set below before allocating any card to System 2.
```
```pbc:outcomes
- Records whether a SINGLE 3090 suffices for the real workload. This is the decisive measurement.
- Records dual scaling separately for tensor-parallel and layer-split frameworks.
- Confirms EVGA/Zotac single-card parity.
```

### The decisive question has changed

The benchmark was originally framed as *"is dual faster than single?"* Given the 2%
workload finding, the decision-relevant question is instead:

> **Is a single RTX 3090 sufficient for Gemma4 at the quality actually required?**

`gemma4:26b` at Q4 is roughly **15–16 GB**, comfortably inside one 3090's 24 GB with
context headroom. A second card is only required at Q8 (~26 GB) or for 70B-class
models (~40 GB at Q4).

**If a single card suffices, the entire dual apparatus — the x4 bottleneck, NVLink,
700W, the mounting work — solves a problem that does not exist**, and the second
3090 becomes a liquid asset rather than a machine to build around.

This question is **open**. It is the one input the supervisor is waiting on.

### Capture set

| Measurement | Purpose |
| --- | --- |
| `lspci -vv \| grep -i LnkSta` | Negotiated width per card; confirms which sits on x4 |
| `nvidia-smi topo -m` | Whether an NVLink bridge is present |
| Single-card tok/s, each card, same model + quant | EVGA vs Zotac parity |
| `gemma4:26b` Q4 on one 3090, quality + tok/s | **Decides the architecture** |
| Dual, model that fits 24 GB | Isolates TP overhead |
| Dual, 70B Q4 | Measures the capacity win single cannot deliver |

## Transitions

```pbc:transitions
- from: current
  to: arch_c
  when: A single 3090 satisfies Gemma4 at required quality.
  note: Cheapest and simplest outcome. Frees one 3090 entirely. Currently uncosted.
- from: current
  to: arch_a
  when: A single 3090 suffices AND a separate machine is not wanted.
  note: Mixed box serves the 2% in place, with no network hop and no wake-on-LAN.
- from: current
  to: arch_b
  when: Workload genuinely needs more than 24GB of VRAM.
  note: Only justified by 70B-class models or Q8. Inherits the x4 ceiling; budget for NVLink.
```

## Pre-registered predictions

Recorded before the benchmark so results cannot be rationalized afterward. Full
reasoning in [`ISSUES.md`](ISSUES.md).

1. **EVGA vs Zotac single-card: parity within 1–3%.** EVGA may throttle sooner under
   sustained load owing to its thinner cooler.
2. **Mixed 3090 + 2080: no pooling benefit; expect ≈ single-3090 or worse.**
3. **True dual 3090:** tensor parallelism **expected to disappoint** on this
   interconnect; layer-split expected to remain usable; the 48 GB capacity win holds
   regardless of link speed.

> **Interpretation warning.** If dual numbers are poor, the cause is most likely the
> x4 PCH link, **not the GPUs**. Do not read that as "dual 3090 is not worth it" —
> that conclusion would be an artifact of this platform.

## Success criteria for supervisor sign-off

- [ ] Benchmark capture set run and results recorded in `ISSUES.md`
- [ ] Explicit answer to: **does one 3090 suffice for Gemma4 at required quality?**
- [ ] Architecture A, B, or C selected, with the deciding measurement cited
- [ ] If B: NVLink presence confirmed or budgeted; suspend/wake-on-LAN plan stated
- [ ] If C: disposition of the freed 3090 stated (sell / redeploy / hold)
- [ ] Pre-registered predictions compared against actuals, including where they were wrong
- [ ] Riser cable model and 180° connector part recorded, so the working dual
      configuration is reproducible

## Open items not blocking this decision

| Item | Status |
| --- | --- |
| Corsair RMA return (dead HX750i) | ⏰ **Not yet shipped.** Window closes ~2026-08-28. Only hard deadline in the project. |
| RM1000x replacement | Ships only after Corsair receives the dead unit. Frees the 850W for System 2. |
| 65W cooler LGA1151 bracket | Unverified — mounting question only |
| Riser cable + 180° connector models | Unrecorded; blocks reproducibility, not the decision |
