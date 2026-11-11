# TestBench single-GPU Qwen3.6 35B 192K profiles

These are separate, loopback-only Ollama instances pinned by GPU UUID. The
Qwen3.6 weights are shared with the default Ollama model store; the two model
tags are small context-profile manifests, not duplicated weight files. Ollama
may spill layers to CPU RAM when one card cannot hold the full model/context.
Each daemon permits one loaded model and one parallel request.

| Pi model | TestBench Ollama port | GPU UUID | Desktop forwarded port |
|---|---:|---|---:|
| `qwen3.6-35b-interactive-ctx192k-gpu0:latest` | 18672 | `GPU-22b9dafe-e97d-dbb2-50ba-2f1f1dea61f9` | 11443 |
| `qwen3.6-35b-interactive-ctx192k-gpu1:latest` | 18673 | `GPU-102e9c9e-f883-58fa-6119-8c72f81fd88e` | 11444 |

Install the profile tags and services on TestBench:

```sh
cd ~/.dotfiles/machines/testbench/ollama-pinned
scp Modelfile.* testbench:/tmp/
ssh testbench 'ollama create qwen3.6-35b-interactive-ctx192k-gpu0:latest -f /tmp/Modelfile.qwen3.6-35b-192k-gpu0 && ollama create qwen3.6-35b-interactive-ctx192k-gpu1:latest -f /tmp/Modelfile.qwen3.6-35b-192k-gpu1'
ssh testbench 'mkdir -p ~/.config/systemd/user'
scp ollama-qwen35-gpu*.service testbench:~/.config/systemd/user/
ssh testbench 'systemctl --user daemon-reload && systemctl --user enable --now ollama-qwen35-gpu0.service ollama-qwen35-gpu1.service'
```

Install the Desktop-side SSH forwards without restarting the existing 11442
Ollama tunnel:

```sh
mkdir -p ~/.config/systemd/user
install -m644 ~/.dotfiles/machines/desktop/ollama-pinned/ollama-testbench-pinned-forward.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now ollama-testbench-pinned-forward.service
```

Validate the tunnels and selected tags:

```sh
curl -fsS http://127.0.0.1:11443/api/tags
curl -fsS http://127.0.0.1:11444/api/tags
ssh testbench 'nvidia-smi --query-gpu=index,uuid,memory.used --format=csv,noheader'
```

After issuing an inference through a Pi route, verify `ollama ps` at the matching
remote port and GPU memory/process placement. The `contextWindow` in Pi is
advertised metadata; the effective context is the loaded model's `CONTEXT` in
`ollama ps`. Avoid loading both profiles concurrently until memory headroom has
been observed for the actual workload.
