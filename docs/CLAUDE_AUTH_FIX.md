# Claude Code Authentication & Mode Switching

## Summary
Resolved an issue where Claude Code was stuck in **API billing mode** (usage-billed) despite the user having a **Pro Subscription**. The cause was `ANTHROPIC_API_KEY` being sourced from a hidden environment file and cached in the window manager's (Sway) environment.

## Symptoms
- `/status` showed `API key: ANTHROPIC_API_KEY` set.
- Session stats showed "Total Cost" in USD rather than "Current session %" usage bars.
- Even after unsetting the variable, it would return in new terminal sessions.

## Root Cause Analysis
1. **Source:** `~/.bashrc` was sourcing `~/.config/anthropic/env`, which contained the `sk-ant-api03...` key.
2. **Persistence:** Sway (the window manager) inherited this environment variable at login. Every new terminal spawned by Sway inherited the variable from Sway's memory, bypassing the fact that the source line in `.bashrc` had been commented out.
3. **Custom Tooling:** The user has a `Claude-Switch` utility in `~/Tools/Claude-Switch/bin/` with aliases `scc`, `acc`, and `ccs` for managing these states.

## Resolution
1. **Code Change:** Commented out the sourcing line in `bash/.bashrc` (linked to `~/.bashrc`).
2. **Hard Disable:** Renamed `~/.config/anthropic/env` to `~/.config/anthropic/env.disabled` to prevent accidental loading via aliases.
3. **Session Reset:** A system reboot (or logging out of Sway) was required to clear the environment variable from the window manager's memory.

## Current Configuration
- **Default Mode:** Subscription (OAuth via `claude.ai`).
- **Verification:** Run `ccs` (custom alias) or `/status` inside Claude. Look for the "Current session %" progress bars to confirm Pro subscription usage.

## Shortcuts Reference (via `~/.bash_aliases`)
- `scc`: Switch to **Subscription** (clears API env vars).
- `acc`: Switch to **API** (currently disabled as the env file is renamed).
- `ccs`: Check current mode status.
- `cl`: Launch `claude`.

---
*Last Updated: April 27, 2026*
