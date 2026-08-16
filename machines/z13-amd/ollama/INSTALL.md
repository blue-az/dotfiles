# Ollama GPU heap on the Z13 (gfx1151 / Radeon 8050S, Vulkan)

Raising the GTT heap so large models fully offload to the iGPU.

## Problem

Any model needing more than ~17.5 GiB of Vulkan heap failed at load:

```
radv/amdgpu: Not enough memory for command submission.
error loading model: vk::Queue::submit: ErrorDeviceLost
```

`gemma4:31b` (dense, 17.37 GiB weights + 1.29 GiB mmproj) hit this on every
attempt. Reducing GPU layers did **not** help — the failure was identical at
50/61, 40/61, 32/61 and 24/61 layers.

## Cause

RADV on an APU exposes one pool built from kernel VRAM + GTT, split 1/3 : 2/3:

```
heap[0] device-local  5.84 GiB
heap[1] host-visible 11.68 GiB
                     ---------
                     17.52 GiB  = 4 GiB VRAM + 13.52 GiB GTT
```

Kernel GTT defaulted to `ttm.pages_limit`, which is half of RAM
(3543756 pages x 4096 = 13.52 GiB).

The reason cutting layers didn't help: after the ollama 0.32.13 upgrade
(binary dated Aug 14), llama.cpp put non-offloaded weights in **`Vulkan_Host`**
pinned buffers instead of mmap'd **`CPU_Mapped`** pages. Pinned host buffers
come out of the *same* RADV pool, so the total never moved:

| GPU layers | Vulkan0 | Vulkan_Host | total |
|---|---|---|---|
| 50/61 | 14657 | 4235 | 18892 MiB |
| 40/61 | 11927 | 6966 | 18893 MiB |
| 32/61 |  9745 | 9148 | 18893 MiB |
| 24/61 |  7534 | 11360 | 18893 MiB |

Always ~1.4 GiB over the 17.5 GiB ceiling. The same model loaded fine on Aug 07
with `CPU_Mapped 17801 MiB + Vulkan0 13565 MiB`, because mmap'd pages cost zero
Vulkan heap.

## Fix

```
sudo grubby --update-kernel=ALL --args="amdgpu.gttsize=20480 ttm.pages_limit=5242880"
```

Both are needed. `amdgpu.gttsize` (MiB) sizes the GTT manager; `ttm.pages_limit`
(4 KiB pages) is the allocation cap that would otherwise still bite. Both `ttm`
and `amdgpu` are modules loaded from initramfs, so cmdline args apply without a
dracut rebuild. Reboot required — the GTT manager is sized at probe.

These are caps, not reservations; raising them costs nothing until a model
actually uses the space.

Revert with:

```
sudo grubby --update-kernel=ALL --remove-args="amdgpu.gttsize ttm.pages_limit"
```

## Result

|  | before | after |
|---|---|---|
| kernel GTT | 13.52 GiB | 20.00 GiB |
| RADV heap total | 17.52 GiB | 24.00 GiB (8 + 16) |
| `gemma4:31b` offload | 46/61, then failed | **61/61** |
| throughput | 8.45 tok/s (partial, `--no-host`) | **11.3 tok/s** |

At 11.3 tok/s the dense 31b pulls ~201 GB/s against a ~256 GB/s theoretical
peak, so that is close to the practical ceiling for this memory system.

The vision projector now fits on the GPU too, so ollama no longer falls back to
`--no-mmproj-offload` (which even the 26b was hitting).

## ROCm comparison

ROCm 7.2 is functional on kernel 7.1.5 and fully offloads both the 12b (49/49)
and 31b (61/61). Direct `llama-server` A/B probes used the same build, GGUF,
4096-token context, and request per model:

| model / measurement | ROCm | Vulkan | ROCm delta |
|---|---:|---:|---:|
| 12b prompt, 2,893 tokens | 498.20 tok/s | 314.00 tok/s | +58.7% |
| 12b generation, 98 tokens | 20.28 tok/s | 27.10 tok/s | -25.2% |
| 31b prompt, 2,893 tokens | 164.17 tok/s | 153.24 tok/s | +7.1% |
| 31b generation, 256 tokens | 7.64 tok/s | 11.19 tok/s | -31.7% |

These are single-run synthetic probes, not a quality benchmark. The 12b chat
correctness check returned the same answer on both backends.

Keep the Vulkan service override. On the production-size 31b, ROCm's prompt
gain was only 7% while generation was 32% slower. ROCm also filled the 20 GiB
GTT pool and left about 2.8 GiB system memory available after the long prompt;
Vulkan split the allocation across VRAM and GTT and left about 7.1 GiB
available.

ROCm memory reporting is not trustworthy near the limit: llama.cpp reported
about 25.5 GiB free against a 20 GiB total pool and printed negative
`unaccounted` memory. Do not rely on its automatic fit decision for a large
model when another model is resident. Confirm `ollama ps` is empty first.

## Memory pressure

Full 31b offload pins ~20 GiB of a 27 GiB pool. Swap here is zram (compressed
RAM), not disk, so it cannot rescue a genuine overcommit. Running the 31b at
large context alongside a heavy browser session will be tight.

## no-host.conf — fallback, not currently installed

If a future model lands in partial-offload territory and overflows again,
`no-host.conf` drops it into `/etc/systemd/system/ollama.service.d/` and sets
`LLAMA_ARG_NO_HOST=1`. That maps to llama-server's `--no-host`
("bypass host buffer allowing extra buffers to be used"), restoring the
`CPU_Mapped` path. Verified working before the kernel change:

```
control:   Vulkan0 13565.92 + Vulkan_Host 5326.95 = 18892 MiB -> ErrorDeviceLost
--no-host: Vulkan0 13565.92 + CPU 2090 + CPU_REPACK 3237       -> loaded, 8.45 tok/s
```

Unnecessary at 61/61 offload, since there are no CPU-side weights to place.

## Which model to actually use

See `characterization/RESULTS.md`. Short version, over 29 graded tasks:

- **26b MoE** for almost everything — 3.5x faster and equal on all short-form
  reasoning, mixed-domain and constraint work.
- **31b dense** for long-context aggregation over many records, and tight
  multi-constraint code generation. It scores 1.00 to the 26b's 0.81 on the
  tier-3 set built for those two axes.

Spending the 31b's wall clock on 26b best-of-5 instead does *not* close the
gap (1.00 vs 0.84 at matched time): the 26b's long-context errors are
systematic, not random, so majority voting reproduces the same wrong answer.
That is the reason to keep the 31b installed, and the reason the GTT change
above matters.
