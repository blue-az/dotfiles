# gemma4 26b (MoE) vs 31b (dense) — Z13 / gfx1151

29 objectively-graded tasks, no LLM judge. Run 2026-08-15 after the GTT heap
change (26b 31/31 layers, 31b 61/61, both fully offloaded).

**The 31b does have a use case.** An earlier 21-task version of this set said
otherwise; that set had saturated, and the conclusion was an artifact of it.

## Result

| condition | overall | wall clock |
|---|---|---|
| 31b dense, single-shot greedy | **0.96** | 629.5s |
| 26b MoE, single-shot greedy   | 0.93 | 177.3s |
| 26b MoE, best-of-5 @ T=0.7    | 0.95 | 863.3s |

| category (n) | 31b n=1 | 26b n=1 | 26b n=5 |
|---|---|---|---|
| reasoning (6)        | 1.00 | 1.00 | 1.00 |
| mixed-domain (4)     | 1.00 | 1.00 | 1.00 |
| constraints (5)      | **0.75** | 0.95 | 0.95 |
| hard-reasoning (4)   | 1.00 | 1.00 | 1.00 |
| hard-constraints (2) | 1.00 | 0.88 | 1.00 |
| codegen (5)          | **1.00** | 0.90 | 0.95 |
| longctx (3)          | **1.00** | 0.67 | 0.67 |

Tiers 1-2 (the first 21 tasks) saturate: 14 of 21 are perfect for every
condition. Tier 3 is where the models separate — **31b 1.00, 26b 0.81**.

## The decisive comparison

Tier 3 at matched wall clock, 157.8s vs 159.5s:

| | score |
|---|---|
| 31b single-shot | **1.00** |
| 26b best-of-5   | 0.84 |

Spending the 31b's wall-clock budget on five 26b samples instead does not buy
back the gap.

## Why best-of-N does not rescue the 26b

On `L2` (sum the units across all 24 CEDAR records in a 140-record log) the 26b
answers **5589** against a true 5726 — and the majority vote lands on 5589 with
**3 of 5 votes**. It is not noisily wrong, it is *consistently* wrong.
Self-consistency corrects random error; this is systematic error, and sampling
five times just reproduces it. On `x5` best-of-5 lifted 0.50 to 0.75 without
reaching a passing solution.

This refutes the prior working assumption that a 5x-faster model running
best-of-N generally beats a slower single-shot one. It holds only when the
faster model's errors are random.

## Where each model actually wins

**31b (dense)** — long-context aggregation over many records, and tight
multi-constraint code generation. On `x5` (n-th prime, no imports, <=10 lines)
the 26b emitted a `for/else` that breaks before appending, producing garbage
primes and never terminating; the 31b got it right.

**26b (MoE)** — everything else, at 3.5x the speed, plus short-form
instruction formatting. The 31b's one clear loss is `c2`, where it produced a
correct bird list and then leaked its own self-verification into the output,
violating "output only the list". Correct reasoning, failed instruction.

## Caveats

- **Codegen best-of-5 selection is optimistic for the 26b.** It picks the
  highest-scoring sample using the hidden tests — closer to oracle selection
  than to anything available at inference. Realistic if you actually run tests,
  but it favours the 26b, and the 26b still lost.
- **Thinking disabled** (`think: false`) for both. Symmetric, but both models
  are below their best absolute capability. The raw GGUFs leak
  `thought`/`step`/`data` channel markers through llama-server and ramble past
  `num_predict`; ollama's API with thinking off was the clean path.
- **Quantization is not matched.** 26b is Q4_K_M at 5.32 BPW, 31b at 4.86 BPW,
  so the 31b carries *more* quantization damage and wins anyway. This compares
  the artifacts on disk, not the underlying models.
- Single seed for greedy conditions; 29 tasks is still a small sample. Three
  long-context tasks is thin evidence for the strongest claim here.
- `c5` (two sentences, exact word counts, no letter 'e') fails at 0.75 for
  everything including best-of-5 — a shared lipogram limit.

## Reproduce

    python3 run.py gemma4:26b 1 out.json TASKS_TIER3
    python3 grade.py a.json b.json c.json

Task sets: `TASKS` (tier 1), `TASKS_HARD` (tier 2), `TASKS_TIER3` (tier 3).
Tier 3 codegen graders AST-check the structural bans, then execute the model's
function against hidden tests in a subprocess; the no-import ban is enforced
before execution and doubles as the safety guard.
