# AI Agent Permission Modes

How the coding agents on this machine are configured for approvals / sandbox /
"dangerous" behavior. Snapshot as of 2026-08-10 (z13 / Fedora).

## Current state (summary)

| Tool | Mode | How configured | Rough risk |
| ---- | ---- | -------------- | ---------- |
| **Grok** | `always-approve` | `~/.grok/config.toml` → `[ui] permission_mode` | Auto-approve tools; deny/hooks can still block |
| **agy** | `--dangerously-skip-permissions` | shell alias in `bash/.bash_aliases` | Auto-approve all tool permission prompts |
| **Codex** | `never` + `danger-full-access` | `~/.codex/config.toml` | No approvals **and** sandbox off |
| **Claude** | `auto` | `~/.claude/settings.json` → `permissions.defaultMode` | Fewer prompts; still safety-checks / escalates |

## Grok

**Config:** `~/.grok/config.toml`

```toml
[ui]
permission_mode = "always-approve"
yolo = false   # legacy key; does NOT control the mode
```

- Product name: **always-approve** (Claude-compatible alias: `bypassPermissions`).
- CLI equivalents: `--always-approve`, `--yolo`, `--permission-mode bypassPermissions`.
- TUI: `/always-approve`, `Ctrl+O`, or `Shift+Tab`.
- Even in always-approve, **deny rules**, **hooks**, and **some shell `ask` rules** can still stop a call.
- OS sandbox is a separate knob (`--sandbox` / sandbox config); always-approve is about permission prompts, not "sandbox off forever."

Modes available: `ask` (default), `acceptEdits`, `auto`, `dontAsk`, `always-approve` / `bypassPermissions`, plus plan mode.

Docs: `~/.grok/docs/user-guide/22-permissions-and-safety.md`

## agy

**Alias:** `bash/.bash_aliases` (stowed to `~/.bash_aliases`)

```bash
alias agy="agy --dangerously-skip-permissions"
```

- Flag meaning: auto-approve all tool permission requests without prompting.
- Only applies when launched as `agy` with aliases enabled.
- Full path (`~/.local/bin/agy`) or no alias expansion → normal permission prompts.
- Closest sibling to Grok always-approve on the permission axis.

## Codex (OpenAI)

**Config:** `~/.codex/config.toml`

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"

[notice]
hide_full_access_warning = true
```

| Setting | Effect |
| ------- | ------ |
| `approval_policy = "never"` | Never ask for user approval on commands |
| `sandbox_mode = "danger-full-access"` | No sandbox; full FS + network |

- One-off CLI: `codex --dangerously-bypass-approvals-and-sandbox` or `codex -a never -s danger-full-access`
- Project trust is separate: many trees under `~/` already have `trust_level = "trusted"` in the same config.
- Restart Codex after config changes; a live session keeps the old policy.
- More aggressive than Grok/agy alone: **approvals + sandbox** both removed.

Before this change, status showed: `Permissions: Workspace (Ask for approval)`.

## Claude Code

**Config:** `~/.claude/settings.json`

```json
{
  "permissions": {
    "defaultMode": "auto"
  }
}
```

- Currently **auto**, not full bypass / dangerous mode.
- Full dangerous equivalent is `--dangerously-skip-permissions` (bypassPermissions).
- Alias `cl="claude"` does **not** force skip-permissions (unlike `agy`).
- Mode switching helpers: `scc` / `acc` / `ccs` via `~/Tools/Claude-Switch/` (subscription vs API, not permission mode).
- Related note: [CLAUDE_AUTH_FIX.md](./CLAUDE_AUTH_FIX.md)

## How they relate

```
more cautious ←————————————————————————————→ more aggressive

Claude (auto)   Grok (always-approve)   agy (skip-perms)   Codex (never + no sandbox)
                     ≈ similar permission skip ≈              + sandbox removed
```

| Dimension | Grok always-approve | agy skip-perms | Codex never + danger-full-access |
| --------- | ------------------- | -------------- | -------------------------------- |
| Tool/command prompts | skipped | skipped | skipped |
| Hard deny / hooks | still apply | (product-dependent) | weaker / different model |
| OS sandbox | separate setting | separate (`--sandbox`) | **off** via `danger-full-access` |

## Files to check

| Path | What |
| ---- | ---- |
| `~/.grok/config.toml` | Grok `permission_mode` |
| `~/.codex/config.toml` | Codex approval + sandbox |
| `~/.claude/settings.json` | Claude `defaultMode` |
| `bash/.bash_aliases` | `agy` alias (and `cl`) |
| `~/.grok/docs/user-guide/22-permissions-and-safety.md` | Grok modes reference |

## Quick change recipes

```bash
# Grok: temporary always-approve for one process
grok --always-approve

# Grok: set default in config
# [ui] permission_mode = "always-approve"   # or "auto", "ask"

# Codex: temporary full bypass
codex --dangerously-bypass-approvals-and-sandbox

# Claude: one-shot dangerous
claude --dangerously-skip-permissions

# agy without the alias (normal prompts)
\agy
# or
~/.local/bin/agy
```

---
*Last updated: 2026-08-10*
