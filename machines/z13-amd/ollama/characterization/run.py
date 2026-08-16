#!/usr/bin/env python3
"""Drive one ollama model through the task set and dump raw results.

Uses ollama's /api/chat rather than raw llama-server: the Ollama-format gemma4
GGUFs leak `thought`/`step`/`data` channel markers when llama-server patches
their chat template, and the unbounded reasoning ramble truncates answers.
Thinking is disabled for BOTH models so the comparison stays symmetric.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tasks as T  # noqa: E402

API = "http://127.0.0.1:11434/api/chat"


def ask(model, prompt, temp, seed):
    body = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False, "think": False, "keep_alive": "15m",
        "options": {"temperature": temp, "seed": seed, "num_predict": 900,
                    "num_ctx": 8192},
    }).encode()
    req = urllib.request.Request(API, data=body,
                                 headers={"Content-Type": "application/json"})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=900) as r:
                d = json.load(r)
            if d.get("error"):
                return f"__ERROR__ {d['error']}"
            return d.get("message", {}).get("content", "")
        except (urllib.error.URLError, TimeoutError, KeyError) as e:
            if attempt == 2:
                return f"__ERROR__ {e}"
            time.sleep(5)


def main():
    model, nsamp, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    TASKS = getattr(T, sys.argv[4] if len(sys.argv) > 4 else "TASKS")
    print(f"[{model}] n={nsamp}", flush=True)
    ask(model, "hi", 0.0, 1)  # force load before timing anything
    results, t_all = {}, time.time()
    for cat, tid, prompt, _ in TASKS:
        samples, t0 = [], time.time()
        for k in range(nsamp):
            temp = 0.0 if nsamp == 1 else 0.7
            samples.append(ask(model, prompt, temp, 1000 + k))
        results[tid] = {"category": cat, "samples": samples,
                        "seconds": round(time.time() - t0, 1)}
        bad = sum(s.startswith("__ERROR__") for s in samples)
        print(f"  {tid} ({cat}) {results[tid]['seconds']}s"
              + (f"  !! {bad} errors" if bad else ""), flush=True)
    payload = {"model": model, "n_samples": nsamp,
               "total_seconds": round(time.time() - t_all, 1), "results": results}
    with open(out, "w") as f:
        json.dump(payload, f, indent=1)
    print(f"[{model}] done in {payload['total_seconds']}s -> {out}", flush=True)


if __name__ == "__main__":
    main()
