#!/usr/bin/env python3
"""Emit a compact, read-only status card for TestBench GPUs (Ollama + llama-server)."""
from __future__ import annotations

import json
import subprocess
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

HOME = Path.home()
REPO = HOME / ".dotfiles"
SERVICE_DIR = REPO / "machines/testbench/ollama-pinned"


def configured_values(gpu: int) -> dict[str, str]:
    path = SERVICE_DIR / f"ollama-qwen35-gpu{gpu}.service"
    values: dict[str, str] = {}
    try:
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.startswith("Environment="):
                key, sep, value = line[len("Environment="):].partition("=")
                if sep:
                    values[key] = value
    except OSError:
        pass
    return values


def context_label(raw: object) -> str:
    try:
        return f"{int(raw) // 1024}K"
    except (TypeError, ValueError):
        return "unknown"


def endpoint_ps(gpu: int) -> tuple[list[dict], str | None]:
    """Query /api/ps for resident Ollama models."""
    port = 11443 + gpu
    request = urllib.request.Request(
        f"http://127.0.0.1:{port}/api/ps", headers={"Accept": "application/json"}
    )
    try:
        with urllib.request.urlopen(request, timeout=0.6) as response:
            models = json.loads(response.read().decode("utf-8")).get("models", [])
        return models, None
    except (OSError, TimeoutError, ValueError, urllib.error.URLError) as exc:
        return [], type(exc).__name__


def endpoint_show(gpu: int, model_name: str) -> dict:
    """Query /api/show for a specific model tag."""
    port = 11443 + gpu
    request = urllib.request.Request(
        f"http://127.0.0.1:{port}/api/show",
        data=json.dumps({"name": model_name}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=0.6) as response:
            return json.loads(response.read().decode("utf-8"))
    except (OSError, TimeoutError, ValueError, urllib.error.URLError):
        return {}


def default_instance_models() -> list[str]:
    """List models resident on the un-pinned default Ollama instance (port 11442)."""
    request = urllib.request.Request(
        "http://127.0.0.1:11442/api/ps", headers={"Accept": "application/json"}
    )
    try:
        with urllib.request.urlopen(request, timeout=0.6) as response:
            data = json.loads(response.read().decode("utf-8"))
        return [m.get("name", "unnamed") for m in data.get("models", [])]
    except (OSError, TimeoutError, ValueError, urllib.error.URLError):
        return []


def gpu_vram(gpu_idx: int) -> int:
    """Return VRAM used in MiB for a GPU on TestBench via nvidia-smi."""
    try:
        out = subprocess.check_output(
            ["ssh", "testbench", "nvidia-smi", "--query-gpu=index,memory.used",
             "--format=csv,noheader", "--id", str(gpu_idx)],
            text=True, timeout=5
        )
        return int(out.strip().split(",")[1].strip().split()[0])
    except Exception:
        return 0


def llama_server_models(gpu_idx: int) -> list[dict]:
    """Query llama-server /models endpoint for loaded models on TestBench."""
    try:
        out = subprocess.check_output(
            ["ssh", "testbench",
             "curl", "-s", "http://127.0.0.1:18091/models"],
            text=True, timeout=5
        )
        data = json.loads(out)
        results = []
        for m in data.get("data", []):
            val = m.get("status", {}).get("value", "")
            if val in ("loaded", "loading", "unloading"):
                alias = (m.get("aliases", [])[0] if m.get("aliases") else m.get("id", "unknown"))
                args = m.get("status", {}).get("args", [])
                info = {}
                for i, a in enumerate(args):
                    if a == "--alias": info["alias"] = args[i + 1]
                    elif a == "--ctx-size": info["ctx"] = args[i + 1]
                    elif a == "--cache-type-k": info["k"] = args[i + 1]
                    elif a == "--cache-type-v": info["v"] = args[i + 1]
                    elif a == "--flash-attn": info["flash"] = args[i + 1]
                    elif a == "--device": info["device"] = args[i + 1]
                    elif a == "--n-gpu-layers": info["ngl"] = args[i + 1]
                    elif a == "--parallel": info["parallel"] = args[i + 1]
                    elif a == "--port": info["port"] = args[i + 1]
                # Try to detect quant from model path or alias
                model_path = info.get("model", "")
                if "q4_K_M" in model_path or "q4k" in model_path.lower():
                    info["quant"] = "Q4_K_M"
                elif "q8_0" in model_path:
                    info["quant"] = "Q8_0"
                elif "q4_0" in model_path:
                    info["quant"] = "Q4_0"
                elif "q4kv" in model_path:
                    info["quant"] = "Q4_K_M"  # q4kv alias
                else:
                    # Check alias for quant hint
                    if "q4kv" in alias.lower() or "q4_k_m" in alias.lower():
                        info["quant"] = "Q4_K_M"
                info["alias"] = info.get("alias", alias)
                results.append(info)
        return results
    except Exception:
        return []


def seat_info(gpu: int, ollama_models: list[dict], ollama_error: str | None,
              ollama_show: dict, values: dict[str, str],
              nvidia_vram: int, llama_models: list[dict],
              default_models: list[str]) -> tuple[str, str, str]:
    """Return (identity_line, detail_line, tooltip)."""
    tooltip_parts: list[str] = []

    # Prefer Ollama resident models
    if ollama_models:
        items = []
        for model in ollama_models:
            name = model.get("name", "unnamed")
            obs_ctx = context_label(model.get("context_length"))
            items.append(f"{name} · context {obs_ctx}")
        identity = f"GPU{gpu}  " + " | ".join(items)
        tooltip_parts.append(f"GPU{gpu}: Ollama resident — {', '.join(items)}")
        quant = "unknown"
        for model in ollama_models:
            tag = model.get("model", model.get("name", ""))
            if tag:
                sd = endpoint_show(gpu, tag)
                if sd:
                    q = sd.get("details", {}).get("quantization_level", "unknown")
                    if q != "unknown":
                        quant = q
                        break
        detail = f"  {quant}"
        if quant == "unknown":
            flash = "On" if values.get("OLLAMA_FLASH_ATTENTION") == "1" else values.get("OLLAMA_FLASH_ATTENTION", "?")
            kv = values.get("OLLAMA_KV_CACHE_TYPE", "?").upper()
            parallel = values.get("OLLAMA_NUM_PARALLEL", "?")
            tooltip_parts.append(f"Flash {flash} · KV {kv} · parallel {parallel}")
        return identity, detail, "\n".join(tooltip_parts)

    # Fall back to llama-server loaded models
    if llama_models:
        for lm in llama_models:
            alias = lm.get("alias", "unknown")
            ctx = lm.get("ctx", "?")
            k_cache = lm.get("k", "?")
            v_cache = lm.get("v", "?")
            flash = lm.get("flash", "?")
            device = lm.get("device", "?")
            ngl = lm.get("ngl", "?")
            parallel = lm.get("parallel", "?")
            quant = lm.get("quant", "unknown")
            identity = f"GPU{gpu}  {alias}"
            detail = f"  {quant}"
            tooltip_parts.append(f"GPU{gpu}: llama-server — {alias}")
            tooltip_parts.append(f"  context {int(ctx)//1024}K · KV {k_cache}/{v_cache} · flash {flash}")
            tooltip_parts.append(f"  device {device} · layers {ngl}/999 · parallel {parallel}")
            tooltip_parts.append(f"  VRAM {nvidia_vram // 1024} GiB (nvidia-smi)")
            return identity, detail, "\n".join(tooltip_parts)

    # Nothing loaded
    profile_ctx = values.get("OLLAMA_CONTEXT_LENGTH", "?")
    try:
        ctx_display = "%dK" % (int(profile_ctx) // 1024)
    except ValueError:
        ctx_display = profile_ctx
    identity = f"GPU{gpu}  No model resident · {ctx_display} profile context"
    detail = f"  {ctx_display}"
    tooltip_parts.append(f"GPU{gpu}: no model resident; {ctx_display} is the configured service default")
    if default_models:
        names = ", ".join(default_models)
        detail = f"  \u26a0 default: {names}"
        tooltip_parts.append(f"\u26a0 un-pinned default Ollama instance (11442) has: {names}")
        tooltip_parts.append("  load through 11443 (gpu0) or 11444 (gpu1) instead")
    return identity, detail, "\n".join(tooltip_parts)


def _gpu_uuid(idx: int) -> str | None:
    """Return the UUID of a TestBench GPU by its index."""
    try:
        out = subprocess.check_output(
            ["ssh", "testbench", "nvidia-smi", "--query-gpu=index,uuid",
             "--format=csv,noheader"],
            text=True, timeout=5
        )
        for line in out.strip().splitlines():
            gidx, uuid = [x.strip() for x in line.split(",")]
            if gidx == str(idx):
                return uuid
    except Exception:
        pass
    return None


def _gpu1_uuid() -> str | None:
    return _gpu_uuid(1)



def main() -> None:
    text_rows = ["TESTBENCH · MODEL STATUS"]
    tooltip_rows = ["TestBench Ollama + llama-server — read-only status"]

    # GPU0
    default_models = default_instance_models()
    gpu0_models, gpu0_error = endpoint_ps(0)
    gpu0_show = {}
    gpu0_values = configured_values(0)
    gpu0_vram = gpu_vram(0)
    gpu0_llama = [m for m in llama_server_models(0) if m.get("device") != "CUDA1"]
    gpu0_identity, gpu0_detail, gpu0_tooltip = seat_info(
        0, gpu0_models, gpu0_error, gpu0_show, gpu0_values, gpu0_vram, gpu0_llama,
        default_models
    )

    # GPU1
    gpu1_models, gpu1_error = endpoint_ps(1)
    gpu1_show = {}
    gpu1_values = configured_values(1)
    gpu1_vram = gpu_vram(1)
    gpu1_llama = [m for m in llama_server_models(0) if m.get("device") == "CUDA1"]
    gpu1_identity, gpu1_detail, gpu1_tooltip = seat_info(
        1, gpu1_models, gpu1_error, gpu1_show, gpu1_values, gpu1_vram, gpu1_llama,
        default_models
    )

    text_rows.append(gpu0_identity)
    text_rows.append(gpu0_detail)
    text_rows.append(gpu1_identity)
    text_rows.append(gpu1_detail)
    tooltip_rows.extend([gpu0_tooltip, gpu1_tooltip])

    timestamp = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %Z")
    tooltip_rows.append(
        f"\nObserved at {timestamp}. Resident models from /api/ps (Ollama) and "
        "/api/models (llama-server) or nvidia-smi VRAM. "
        "API residency does not prove which client is routing requests."
    )
    print(json.dumps({
        "text": "\n".join(text_rows),
        "tooltip": "\n".join(tooltip_rows),
        "class": "testbench-llm",
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
