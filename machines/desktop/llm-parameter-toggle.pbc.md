---
id: pbc-desktop-llm-parameter-toggle
title: Desktop LLM parameter toggle
context: desktop-local-llm
status: draft
updated: 2026-11-15
related:
  - pbc-sway-model-control-menu
  - pbc-local-model-seat-selection-display
tags:
  - desktop
  - llm
  - model-parameters
  - sway
  - private
---

# Desktop LLM parameter toggle

## Promise

A separate desktop keybinding opens a compact, local, text-first readout near the
top-center of the screen, with its right edge aligned to the screen's horizontal
midpoint (right-justified against center). Use the existing Mod+T two-menu overlay
interaction as a familiar pattern without changing those menus or their binding. The readout describes
the choices embedded in the currently loaded model selection: model identity, context,
generation parameters, behavior modes, and relevant serving/runtime choices where
observable. It shows each value and its source/status in plain language. This is
inspection only: it does not edit, apply, reset, or duplicate the controls that own those
settings. Opening or dismissing it never changes model state or sends inference.

**Draft specification only.** This file authorizes no implementation, keybinding,
configuration edit, service/API call, model request, or deployment.

## Grounding and boundary

This contract is grounded in two artifacts:

- The October 19, 2026 Luna Pi conversation, preserved in
  `/home/blueaz/.pi/agent/sessions/--home-blueaz-.dotfiles--/2026-10-19T10-49-48-928Z_01a153c8-287f-7017-8367-f370b658f269.jsonl`. It documents the desktop Pi model picker, Testbench Ollama routes, model IDs, and `samplingParams` such as temperature, top-p, top-k, and output limits. It also records that a working route can still be undermined by stale model IDs or a failed SSH tunnel.
- Two locally moved visual references, both under `/home/blueaz/Python/project-phoenix/docs/handoffs/session_logs/`:
  - `llm-cockpit-jetplane-reference-20261115.png`: the first user's jetplane-like cockpit reference, with card selection, payload/loadout, dials, switches, command preview, and safety/arm affordances.
  - `llm-cockpit-strate-other-user-angle-20261115.png`: another user's Strate-branded dashboard angle, with multi-GPU telemetry, model/context/runtime status, and generation-speed display.
  These are visual inspiration, not evidence that their controls map directly to this desktop's backend or that any parameter value is effective.

Related design contracts:

- `machines/desktop/opencode/` and `~/.pi/agent/models.json` (local runtime configuration, not to be edited by this PBC) define current picker routes and configured sampling parameters.
- `machines/desktop/ollama-pinned/` and the Testbench serving configuration define route-specific model profiles where present.
- `machines/desktop/gpu-architecture-decision.pbc.md` covers hardware architecture decisions, not generation controls.
- Project Phoenix `docs/specs/sway-model-control-menu.pbc.md` covers model/preset visibility and residency actions. This parameter surface is narrower: it MUST NOT load/unload models or replace the picker/control menu.

Paths and settings discovered in the historical conversation are dated evidence, not
assumptions about current live state. Revalidate them read-only before implementation.

## Scope

- A toggleable desktop UI for inspecting and, where the client/backend supports it,
  changing LLM generation parameters for subsequent requests.
- The selected route/model identity and source/effective value of each displayed field.
- Read-only explanation of the loaded model's current choices, separating configured, backend-baked, request-level, observed-effective, unsupported, and unknown values.

Inventory the loaded route's actual choices and classify them as generation values
(temperature, top-p, top-k, min-p, penalties, seed, output cap); behavior modes
(thinking on/off and budget, if supported); and serving/runtime settings (model,
context, GPU placement, slots, cache, speculation). Present plain labeled rows such as
`Temperature: 0.8 — backend default` or `Thinking: on — request override`, with a clear
status for observed, configured-only, unsupported, or unknown. This surface is strictly
read-only. Context length is a serving choice, not a generation parameter; report it as
configured or observed without implying the UI can change it.

## Non-goals

- Selecting, downloading, loading, unloading, or migrating models; changing GPU placement,
  context allocation, routes, SSH tunnels, services, or backend configuration.
- Replacing Pi's model picker, OpenCode settings, or the broader Sway model-control menu.
- Sending prompts, hidden smoke tests, or benchmark requests to verify a change.
- Promising that every parameter is accepted or behaves identically across Ollama,
  llama.cpp, OpenAI-compatible endpoints, models, or harnesses.
- Applying arbitrary sliders to existing validated benchmark results or rewriting their
  evidence/provenance.

## Actors

```pbc:actors
- id: operator
  name: Human desktop operator
  type: external
  description: Inspects the loaded model's current settings and choices.
- id: toggle_ui
  name: Desktop LLM parameter surface
  type: system
  description: Presents loaded-route identity, current parameter values, provenance, and observation status.
- id: client
  name: Pi or other configured inference client
  type: external
  description: Sends requests using its active settings and route.
- id: backend
  name: Configured inference endpoint
  type: external
  description: May supply baked defaults or accept request-level overrides.
```

## State model

```pbc:states
- id: closed
  definition: UI hidden; parameters and inference state are unchanged.
- id: inspecting
  definition: UI open with route and parameter values, provenance, and freshness status.
- id: unavailable
  definition: Route metadata is unavailable or stale; unknown values and source status are clearly identified.
```

## Recommended text-first layout

- **Loaded model:** exact model ID, provider/route, endpoint state, and observation timestamp.
- **Generation:** a compact list of current values and provenance for supported sampling/output controls.
- **Behavior:** current thinking/reasoning mode or related behavior flags, where observable.
- **Serving/runtime:** context, placement, cache, slots, speculation; label these as runtime choices, separate from generation parameters.
- **Status legend:** effective/observed, configured-only, unsupported, unknown, or stale.

Use the cockpit images to identify which choices users need to see and how to group them,
not as a dashboard to clone. This is a textual status readout: no editable widgets, profiles,
apply/reset/cancel actions, decorative gauges, or aircraft skin.

## Information and provenance

For every parameter, show:

| Attribute | Requirement |
|---|---|
| Name/value | Human-readable value and units/range where meaningful. |
| Scope | Backend baked default, client/model configuration, request override, or observed runtime value. |
| Source | Named config/API source when known; never infer a value from model name alone. |
| Effective status | Confirmed effective, configured-only, unsupported, stale, or unknown. |
| Effect | Whether saved value applies to the next request, new conversation, or requires an external restart/reload. |

The header identifies provider, exact model ID, endpoint label, and freshness/availability.
Never display secrets, prompt contents, or credentials. An unreachable endpoint must not
be treated as proof that the configured values are effective.

## Rules

```pbc:rules
- id: DLPT-RUL-001
  name: Toggle is read-only
  rule: Opening, closing, refreshing, or navigating the UI MUST NOT send inference, mutate settings, change routes, load/unload models, or restart services.
  trust: proposed
- id: DLPT-RUL-002
  name: Strictly read-only
  rule: The surface MUST NOT expose edits, apply/reset actions, or persistence. It describes current choices only; future editing requires a separately approved contract.
  trust: proposed
- id: DLPT-RUL-003
  name: Honest value provenance
  rule: The UI MUST distinguish backend-baked defaults, client configuration, request overrides, and observed runtime values. A configured value MUST NOT be labelled effective without readback or other declared evidence.
  trust: proposed
- id: DLPT-RUL-004
  name: Respect capability and evidence
  rule: Show only source-backed values for the loaded route; unsupported fields remain identified as unsupported and unavailable facts are unknown, never guessed from model names.
  trust: proposed
- id: DLPT-RUL-005
  name: Preserve route and model identity
  rule: The readout MUST NOT alter provider, endpoint, model ID, context allocation, or residency. Route changes belong to the model picker.
  trust: proposed
- id: DLPT-RUL-006
  name: No hidden test request
  rule: Opening or refreshing the readout MUST NOT issue a generation request or benchmark.
  trust: proposed
- id: DLPT-RUL-008
  name: Observation failure is visible
  rule: If a source is unavailable or stale, show that condition and timestamp; do not present configured values as effective or silently substitute another route.
  trust: proposed
- id: DLPT-RUL-009
  name: No evidence mutation
  rule: The readout MUST NOT edit benchmark protocols, results, scorecards, or historical evidence. Results remain tied to the exact configuration under which they were measured.
  trust: proposed
- id: DLPT-RUL-010
  name: Local privacy and keyboard access
  rule: The UI MUST omit secrets and prompt text, support keyboard navigation with visible focus, and close without affecting inference or unrelated overlays.
  trust: proposed
```

## Main workflow

1. Operator invokes the separately approved desktop toggle; the UI opens without side effects.
2. UI identifies the current route and shows source-backed values, support, and freshness.
3. UI presents the current parameter and behavior choices with their source and observation status.
4. Operator reads the explanation; no mutation or inference action is available.

## Acceptance scenarios

| ID | Scenario | Expected result |
|---|---|---|
| DLPT-ACC-001 | Toggle open/close repeatedly; Escape; rapid presses | One surface, clean dismissal, no duplicate process, no settings or model-state changes. |
| DLPT-ACC-002 | Inspect with an unavailable endpoint | Route/configured values remain distinguishable from effective values; no inference call occurs. |
| DLPT-ACC-003 | Inspect route with backend defaults and request overrides | Values are separated by source/scope; no value is mislabeled effective without evidence. |
| DLPT-ACC-004 | Inspect a route with missing parameter support/readback | Unsupported, unknown, and stale states are explicit; no inferred values appear. |
| DLPT-ACC-005 | Attempt to find an edit/apply action | None exists; all displayed controls are informational only. |
| DLPT-ACC-006 | Source/endpoint unavailable | Readout reports unavailable/stale with timestamp; no fallback or mutation occurs. |
| DLPT-ACC-007 | Inspect context and model identity | Context is marked read-only; no endpoint, model ID, allocation, or residency changes are possible. |
| DLPT-ACC-008 | Inspect linked benchmark evidence | Evidence remains linked to its original exact configuration; the readout does not alter or imply new results. |
| DLPT-ACC-009 | Keyboard-only use at supported display sizes | All controls are reachable, focus is visible, and content does not obscure or break existing desktop controls. |
| DLPT-ACC-010 | Inspect the control surface | Current choices are described as labeled text rows with source and observation status; no edit affordance or duplicate profile catalog is presented. |
| DLPT-ACC-011 | Route lacks support for top-k or thinking mode | Unsupported control is marked unavailable and cannot be applied; other supported fields remain usable. |
| DLPT-ACC-012 | Inspect cockpit-inspired layout | Sampling controls, behavior switches, route identity, and unrelated runtime/serving controls are visibly separated; no control implies a model load or inference action. |

## Open decisions before implementation

- Which client is the initial target: Pi, OpenCode, or both? The October Luna conversation
  is specifically about Pi's picker and route configuration; it does not establish a UI
  extension mechanism or the desired persistence layer.
- Is this a small popup, a Sway/Waybar surface, or a Pi-side control? Screenshot supplies
  visual context only; it does not decide placement or interaction.
- Which shortcut is conflict-free? Do not reuse Mod+T, already used for the monitor overlay.
- Which parameters and ranges are actually supported by each selected route/client?
- What read-only metadata source and safe persistence API can be used without duplicating
  mutable model configuration?
- Choose a new, conflict-checked keybinding; preserve Mod+T and its two existing menus. Validate the top-center placement with the readout's right edge aligned to screen center against desktop outputs and existing overlays.

Any future editing requires a separate contract and approval. This readout requires a current
read-only inspection of client configuration, loaded-route observability, and shortcut use.
