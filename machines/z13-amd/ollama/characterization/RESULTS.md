# gemma4 26b (MoE) vs 31b (dense) — Z13 / gfx1151

21 objectively-graded tasks, no LLM judge. Run 2026-08-15 after the GTT heap
change (both models fully offloaded: 26b 31/31, 31b 61/61).

## Result

| condition | overall | wall clock |
|---|---|---|
| 31b dense, single-shot greedy | **0.94** | 471.7s |
| 26b MoE, single-shot greedy   | **0.98** | 141.5s |
| 26b MoE, best-of-5 @ T=0.7    | **0.99** | 703.8s |

| category (n tasks) | 31b n=1 | 26b n=1 | 26b n=5 |
|---|---|---|---|
| reasoning (6)        | 1.00 | 1.00 | 1.00 |
| mixed-domain (4)     | 1.00 | 1.00 | 1.00 |
| constraints (5)      | 0.75 | 0.95 | 0.95 |
| hard-reasoning (4)   | 1.00 | 1.00 | 1.00 |
| hard-constraints (2) | 1.00 | 0.88 | 1.00 |

**The 26b wins on both axes.** Single-shot it scores higher than the 31b *and*
runs 3.3x faster. Best-of-5 was never needed — the cheap condition already won.

## Findings

1. **No 31b advantage was found.** 14 of 21 tasks are perfect for every
   condition. Both tiers saturated, including the tier built specifically to
   bite (modular exponentiation, memoised-recursion trace, constraint stacking).
2. **The 31b's only loss is formatting, not capability.** On `c2` it produced
   the correct bird list, then leaked its own self-verification into the output,
   violating "output only the list". Its reasoning was right; its
   instruction-following was not.
3. **Shared blind spot:** `c5` (two sentences, exact word counts, no letter 'e')
   fails at 0.75 for everything, including best-of-5. A real lipogram limit.
4. **Best-of-5 bought one task** (`h5`, 0.75 -> 1.00) for 5x the tokens.

## Caveats — what this does NOT show

- **Ceiling effect.** The set bounds the gap; it does not prove equivalence. A
  31b advantage may exist above this difficulty. The honest claim is "no
  advantage at this level", not "no advantage".
- **Thinking disabled** (`think: false`) for both. Symmetric, so the comparison
  holds, but both models are below their best absolute capability. The raw
  GGUFs leaked `thought`/`step`/`data` channel markers via llama-server and
  rambled past `num_predict`; ollama's API with thinking off was the clean path.
- **Quantization is not matched.** 26b is Q4_K_M at 5.32 BPW, 31b at 4.86 BPW.
  The 31b carries more quantization damage. This compares the artifacts on
  disk, not the underlying models.
- Single seed for greedy conditions; 21 tasks is a small sample.

## Reproduce

    python3 run.py gemma4:26b 1 out.json            # first tier
    python3 run.py gemma4:26b 5 out.json TASKS_HARD # hard tier, best-of-5
    python3 grade.py a.json b.json c.json
