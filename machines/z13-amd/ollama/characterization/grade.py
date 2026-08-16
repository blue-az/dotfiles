#!/usr/bin/env python3
"""Grade the raw run dumps and print the comparison table."""
import json
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tasks import ALL_TASKS, VOTE_MODE, extract_answer, _norm  # noqa: E402

GRADERS = {tid: (cat, fn) for cat, tid, _, fn in ALL_TASKS}


def score_task(tid, samples):
    """Return (score, detail) applying the category's selection rule."""
    cat, fn = GRADERS[tid]
    if len(samples) == 1:
        return fn(samples[0])
    if VOTE_MODE[cat] == "majority":
        votes = Counter(_norm(extract_answer(s)) for s in samples)
        votes.pop("", None)
        if not votes:
            return 0.0, "no answers"
        winner, n = votes.most_common(1)[0]
        for s in samples:
            if _norm(extract_answer(s)) == winner:
                sc, got = fn(s)
                return sc, f"{got} ({n}/{len(samples)} votes)"
    best = max((fn(s) for s in samples), key=lambda x: x[0])
    return best[0], f"{best[1]} (best of {len(samples)})"


def load(path):
    with open(path) as f:
        return json.load(f)


def main():
    runs = [load(p) for p in sys.argv[1:]]
    labels = [f"{r['model'].replace('gemma4:','')} n={r['n_samples']}" for r in runs]

    per_task = {}
    CATS = []
    for r in runs:
        for tid, rec in r["results"].items():
            per_task.setdefault(tid, []).append(score_task(tid, rec["samples"]))
            if GRADERS[tid][0] not in CATS: CATS.append(GRADERS[tid][0])

    w = max(len(l) for l in labels) + 2
    print("\nPER-TASK SCORE")
    print("task  cat          " + "".join(l.ljust(w) for l in labels))
    for cat in CATS:
        for tid in [t for t in per_task if GRADERS[t][0] == cat]:
            cells = "".join(f"{s:.2f}".ljust(w) for s, _ in per_task[tid])
            print(f"{tid:5} {cat:12} {cells}")

    print("\nCATEGORY MEAN")
    print("category      " + "".join(l.ljust(w) for l in labels))
    for cat in CATS:
        tids = [t for t in per_task if GRADERS[t][0] == cat]
        row = ""
        for i in range(len(runs)):
            m = sum(per_task[t][i][0] for t in tids) / len(tids)
            row += f"{m:.2f}".ljust(w)
        print(f"{cat:13} {row}")
    row = ""
    for i in range(len(runs)):
        m = sum(v[i][0] for v in per_task.values()) / len(per_task)
        row += f"{m:.2f}".ljust(w)
    print(f"{'OVERALL':13} {row}")

    print("\nWALL CLOCK")
    for r, l in zip(runs, labels):
        print(f"  {l:16} {r['total_seconds']:>7.1f}s")

    print("\nDETAIL (non-perfect only)")
    for cat in CATS:
        for tid in [t for t in per_task if GRADERS[t][0] == cat]:
            for (s, d), l in zip(per_task[tid], labels):
                if s < 1.0:
                    print(f"  {tid:4} {l:14} {s:.2f}  {str(d)[:70]}")


if __name__ == "__main__":
    main()
